module Backoffice
  class ProfilesController < BaseController
    before_action :set_profile, only: %i[edit update card card_preview card_pdf card_png illustration_editor illustration_position render_to_catalog]

    # GET /backoffice/profiles
    def index
      incoming = params.permit(:faction, :search, :sort, :dir).to_h.compact_blank

      if incoming.any?
        session[:profile_filter] = incoming
        filter = incoming
      else
        filter = session[:profile_filter].presence || {}
      end

      # card_references eager-loaded for the internal_version column.
      @profiles = Catalog::Profile.includes(:card_references)
      @profiles = @profiles.where(faction: filter["faction"]) if filter["faction"].present?
      @profiles = @profiles.where("name ILIKE ?", "%#{filter["search"]}%") if filter["search"].present?

      sort_col = %w[name ducats].include?(filter["sort"]) ? filter["sort"] : "name"
      sort_dir = filter["dir"] == "desc" ? "desc" : "asc"
      @profiles = @profiles.order("#{sort_col} #{sort_dir}")

      @sort   = sort_col
      @dir    = sort_dir
      @filter = filter
    end

    # GET /backoffice/profiles/:id/edit
    def edit
    end

    # POST /backoffice/profiles/:id/card_preview
    #
    # The card as the editor's form currently describes it, rather than as the database has it:
    # the profile is loaded, the submitted attributes are assigned *in memory*, and the card
    # template is rendered from that. Nothing is saved.
    #
    # It renders the very template Grover screenshots (single face, @side set), so the preview is
    # not an approximation of the card — it is the card, minus the trip through Chrome.
    def card_preview
      @profile.assign_attributes(profile_params)
      @side = params[:side] == "back" ? "back" : "front"
      @illustration = @profile.illustrations.find_by(number: params[:illustration]) ||
                      @profile.illustrations.first

      render :card, layout: false
    end

    # PATCH /backoffice/profiles/:id
    #
    # The catalog is now authored here rather than in db/seeds, so this is the one place a stat can
    # change. Saving does not re-render the card: the profile's cards simply start reporting as
    # stale (Catalog::CardReference#stale?) and the render queue picks them up.
    def update
      if @profile.update(profile_params)
        redirect_to edit_backoffice_profile_path(@profile),
          notice: "Saved #{@profile.name}. Its card is now out of date — render it to publish the change."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # GET /backoffice/profiles/:id/card
    def card
      filter = if params[:faction].present? || params[:sort].present? || params[:search].present?
        params.permit(:faction, :search, :sort, :dir).to_h
      else
        session[:profile_filter].presence || {}
      end

      scope = Catalog::Profile.all
      scope = scope.where(faction: filter["faction"]) if filter["faction"].present?
      scope = scope.where("name ILIKE ?", "%#{filter["search"]}%") if filter["search"].present?
      sort_col = %w[name ducats].include?(filter["sort"]) ? filter["sort"] : "name"
      sort_dir = filter["dir"] == "desc" ? "desc" : "asc"
      scope = scope.order("#{sort_col} #{sort_dir}")

      ids = scope.pluck(:id)
      idx = ids.index(@profile.id)
      @prev_profile_id = ids[idx - 1] if idx && idx > 0
      @next_profile_id = ids[idx + 1] if idx
      @query_params = filter
      @side = params[:side].presence
      # Which illustration the front face draws. Grover screenshots the page as it first loads, so
      # this param — not the in-page ⇄ swap button — is what selects the art in a rendered card.
      @illustration = @profile.illustrations.find_by(number: params[:illustration]) ||
                      @profile.illustrations.first
      render layout: false
    end

    # GET /backoffice/profiles/:id/card_pdf
    def card_pdf
      front = render_card_png(@profile, "front")
      back  = render_card_png(@profile, "back")
      send_data build_pdf_from_pngs([ front, back ]),
        filename: "#{@profile.name.parameterize}.pdf",
        type: "application/pdf",
        disposition: "attachment"
    end

    # GET /backoffice/profiles/:id/card_png
    def card_png
      side = params[:side].presence || "front"
      number = params[:illustration].presence
      png = render_catalog_png(@profile, side, illustration: number)

      ref = @profile.card_references.find_by(illustration_number: number || 1) ||
            @profile.card_references.first
      send_data png,
        filename: side == "front" ? ref.card_front : ref.card_back,
        type: "image/png",
        disposition: "attachment"
    end

    # GET /backoffice/profiles/export_pdf
    #
    # One printable card per card reference: an A/B pair yields two fronts with different art, each
    # followed by its own copy of the shared back so the pages still pair up front/back for duplex.
    def export_pdf
      pngs = export_scope.includes(:card_references).flat_map do |profile|
        back = render_card_png(profile, "back")
        profile.card_references.flat_map do |cr|
          [ render_card_png(profile, "front", illustration: cr.illustration_number), back ]
        end
      end

      label = params[:faction].presence || "selection"
      send_data build_pdf_from_pngs(pngs),
        filename: "carnevale-cards-#{label}.pdf",
        type: "application/pdf",
        disposition: "attachment"
    end

    # GET /backoffice/profiles/export_png
    def export_png
      require "zip"

      # Mirrors the catalog layout: both faces of every card reference.
      zip_data = Zip::OutputStream.write_buffer do |zip|
        export_scope.includes(:card_references).each do |profile|
          back = render_catalog_png(profile, "back")
          profile.card_references.each do |cr|
            zip.put_next_entry(cr.card_front)
            zip.write(render_catalog_png(profile, "front", illustration: cr.illustration_number))
            zip.put_next_entry(cr.card_back)
            zip.write(back)
          end
        end
      end

      label = params[:faction].presence || "selection"
      send_data zip_data.string,
        filename: "carnevale-cards-#{label}.zip",
        type: "application/zip",
        disposition: "attachment"
    end

    # POST /backoffice/profiles/:id/render_to_catalog
    #
    # Render this profile's cards into public/cards, then bump internal_version for the ones whose
    # bytes changed (via cards:reversion). The /api/v1/cards/manifest endpoint immediately reflects
    # the new version, so the Flutter client re-syncs just those cards.
    #
    # Every card reference gets both of its faces. The front is drawn with the reference's own
    # illustration, so an A/B pair delivers two different cards; the back has no illustration, so
    # it is rendered once and written to each reference.
    # Also answers JSON, which is what the render queue (see #render_queue) drives it with, one
    # profile per request.
    def render_to_catalog
      refs = @profile.card_references.to_a
      if refs.empty?
        message = "No card reference to render for #{@profile.name}."
        respond_to do |format|
          format.html { redirect_back fallback_location: card_backoffice_profile_path(@profile), alert: message }
          format.json { render json: { error: message }, status: :unprocessable_entity }
        end
        return
      end

      FileUtils.mkdir_p(Catalog::CardReference::IMAGES_DIR)
      refs.each do |cr|
        File.binwrite(cr.front_path, render_catalog_png(@profile, "front", illustration: cr.illustration_number))
      end

      back_png = render_catalog_png(@profile, "back")
      refs.each { |cr| File.binwrite(cr.back_path, back_png) }

      # Same version-bump rule as `rake cards:reversion`, applied to just this profile's refs so
      # the manifest advertises a new internal_version only when the rendered bytes actually change.
      outcomes = refs.map(&:reversion!)

      # The images now match the current stats and art, so record what they were rendered from —
      # that baseline is what makes these cards stop reporting as stale.
      refs.each(&:stamp_source!)

      versions = @profile.card_references.reload.map(&:internal_version).uniq.sort
      respond_to do |format|
        format.html do
          redirect_to card_backoffice_profile_path(@profile),
            notice: "Rendered #{@profile.name} into the catalog (internal_version now #{versions.join(", ")})."
        end
        format.json do
          render json: {
            id: @profile.id,
            name: @profile.name,
            cards: refs.size,
            bumped: outcomes.count(:bumped),
            versions: versions
          }
        end
      end
    rescue StandardError => e
      # One profile failing to render (a Chrome hiccup, a missing illustration file) must not take
      # the whole queue down with it: report it and let the page carry on to the next profile.
      Rails.logger.error("render_to_catalog failed for profile #{@profile.id}: #{e.class}: #{e.message}")
      respond_to do |format|
        format.html { redirect_to card_backoffice_profile_path(@profile), alert: "Render failed: #{e.message}" }
        format.json { render json: { id: @profile.id, name: @profile.name, error: e.message }, status: :internal_server_error }
      end
    end

    # GET /backoffice/profiles/render_queue
    #
    # The catalog's render queue: the profiles whose cards are out of date, or the whole catalog
    # with ?scope=all. The rendering itself is driven from the page, one POST to render_to_catalog
    # per profile, because a single request rendering hundreds of faces through headless Chrome
    # would run for minutes and time out — and a request per profile is also what lets the page
    # show progress and survive being closed halfway.
    def render_queue
      @scope = params[:scope] == "all" ? "all" : "stale"

      refs = Catalog::CardReference.includes(profile: [
        :illustrations,
        { profile_weapons: :weapon },
        { profile_special_rules: :special_rule }
      ]).to_a
      stale = refs.select(&:stale?)

      @total_count = refs.size
      @stale_count = stale.size
      @stale_profile_ids = stale.map(&:profile_id).to_set

      queued = @scope == "all" ? refs : stale
      @profiles = queued.map(&:profile).uniq.sort_by { |p| [ p.faction.to_s, p.name.to_s ] }
    end

    # GET /backoffice/profiles/:id/illustration_editor
    def illustration_editor
      number = params[:number]&.to_i || 1
      @illustration = @profile.illustrations.find_by!(number: number)
      render layout: false
    end

    # PATCH /backoffice/profiles/:id/illustration_position
    def illustration_position
      number = params[:number]&.to_i || 1
      illustration = @profile.illustrations.find_by(number: number) ||
                     @profile.illustrations.build(path: "", number: number)
      illustration.update!(
        offset_x: params[:offset_x].to_i.clamp(-2000, 2000),
        offset_y: params[:offset_y].to_i.clamp(-2000, 2000),
        zoom:     params[:zoom].to_i.clamp(10, 500),
        flipped:  params[:flipped] == "1"
      )
      redirect_to card_backoffice_profile_path(@profile, params.permit(:faction, :search, :sort, :dir))
    end

    private

    def set_profile
      @profile = Catalog::Profile.includes(:weapons, :special_rules, :illustrations).find(params.expect(:id))
    end

    # Abilities and keywords are json arrays of strings, edited as one-per-line textareas — the
    # form's only concession to their shape, and cheaper to use than a row of nested fields.
    def profile_params
      permitted = params.expect(profile: [
        :name, :faction, :version, :abilities_text, :keywords_text, *Catalog::Profile::STATS
      ])

      permitted
        .except(:abilities_text, :keywords_text)
        .to_h
        .merge(
          abilities: text_to_list(permitted[:abilities_text]),
          keywords: text_to_list(permitted[:keywords_text])
        )
    end

    def text_to_list(text)
      text.to_s.split("\n").map(&:strip).compact_blank
    end

    def export_scope
      scope = params[:ids].present? ? Catalog::Profile.where(id: params[:ids]) : Catalog::Profile.all
      scope = scope.where(faction: params[:faction]) if params[:faction].present?
      sort_col = %w[name ducats].include?(params[:sort]) ? params[:sort] : "name"
      sort_dir = params[:dir] == "desc" ? "desc" : "asc"
      scope.order("#{sort_col} #{sort_dir}")
    end

    # Internal URL Grover's headless Chrome navigates to. Carries the render token so the
    # gated `card` action serves it without a Devise session (see BaseController).
    #
    # Defaults to the request's own base URL (correct in development). In production, set
    # CARD_RENDER_BASE_URL to the container-internal address (e.g. http://localhost, where
    # Thruster listens) so Chrome loops straight back to Puma instead of hair-pinning out to
    # the public host and back through kamal-proxy.
    def card_url_for(profile, side, illustration: nil)
      base = ENV["CARD_RENDER_BASE_URL"].presence || request.base_url
      card_backoffice_profile_url(profile, host: base, side: side, illustration: illustration,
        render_token: BaseController.render_token)
    end

    # Transparent rounded corners — for the images the app downloads.
    def render_catalog_png(profile, side, illustration: nil)
      Grover.new(card_url_for(profile, side, illustration: illustration), **grover_png_options).to_png
    end

    # Opaque background — an intermediate step towards a printable PDF.
    def render_card_png(profile, side, illustration: nil)
      Grover.new(card_url_for(profile, side, illustration: illustration), **grover_png_for_pdf_options).to_png
    end

    # PNG options for card exports and catalog images (transparent rounded corners).
    def grover_png_options
      {
        emulate_media: "screen",
        viewport: { width: 265, height: 454, device_scale_factor: 3 },
        print_background: true,
        omit_background: true,
        launch_args: [ "--no-sandbox", "--disable-setuid-sandbox" ]
      }
    end

    # PNG options used as an intermediate step for PDF generation (opaque background).
    def grover_png_for_pdf_options
      {
        emulate_media: "screen",
        viewport: { width: 265, height: 454, device_scale_factor: 3 },
        print_background: true,
        launch_args: [ "--no-sandbox", "--disable-setuid-sandbox" ]
      }
    end

    # Assemble a multi-page PDF from raw PNG binaries using Prawn. Each PNG becomes one
    # 70mm × 120mm page — no CSS tiling patterns, so every PDF viewer renders identically.
    def build_pdf_from_pngs(png_list)
      require "prawn"
      pt_w = 70  * 72.0 / 25.4  # 198.425 pt
      pt_h = 120 * 72.0 / 25.4  # 340.157 pt

      pdf = Prawn::Document.new(page_size: [ pt_w, pt_h ], margin: 0)
      png_list.each_with_index do |png_data, i|
        pdf.start_new_page if i > 0
        pdf.image StringIO.new(png_data), at: [ 0, pt_h ], fit: [ pt_w, pt_h ]
      end
      pdf.render
    end
  end
end
