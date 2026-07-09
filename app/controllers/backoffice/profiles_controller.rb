module Backoffice
  class ProfilesController < BaseController
    before_action :set_profile, only: %i[show card card_pdf card_png illustration_editor illustration_position render_to_catalog]

    # GET /backoffice/profiles
    def index
      incoming = params.permit(:faction, :search, :sort, :dir).to_h.compact_blank

      if incoming.any?
        session[:profile_filter] = incoming
        filter = incoming
      else
        filter = session[:profile_filter].presence || {}
      end

      @profiles = Catalog::Profile.all
      @profiles = @profiles.where(faction: filter["faction"]) if filter["faction"].present?
      @profiles = @profiles.where("name ILIKE ?", "%#{filter["search"]}%") if filter["search"].present?

      sort_col = %w[name ducats].include?(filter["sort"]) ? filter["sort"] : "name"
      sort_dir = filter["dir"] == "desc" ? "desc" : "asc"
      @profiles = @profiles.order("#{sort_col} #{sort_dir}")

      @sort   = sort_col
      @dir    = sort_dir
      @filter = filter
    end

    # GET /backoffice/profiles/:id
    def show
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
      png  = Grover.new(card_url_for(@profile, side), **grover_png_options).to_png
      send_data png,
        filename: "#{@profile.faction.parameterize}-#{@profile.name.parameterize}-#{side}.png",
        type: "image/png",
        disposition: "attachment"
    end

    # GET /backoffice/profiles/export_pdf
    def export_pdf
      pngs = export_scope.flat_map do |profile|
        [ render_card_png(profile, "front"), render_card_png(profile, "back") ]
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

      zip_data = Zip::OutputStream.write_buffer do |zip|
        export_scope.each do |profile|
          %w[front back].each do |side|
            png = Grover.new(card_url_for(profile, side), **grover_png_options).to_png
            zip.put_next_entry("#{profile.faction.parameterize}-#{profile.name.parameterize}-#{side}.png")
            zip.write(png)
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
    # Render this profile's card faces and write them into public/cards under the filenames its
    # CardReferences already point at, then bump internal_version for the ones whose bytes changed
    # (via cards:reversion). The /api/v1/cards/manifest endpoint immediately reflects the new
    # version, so the Flutter client re-syncs just this card.
    def render_to_catalog
      refs = @profile.card_references.select { |cr| cr.card_front.present? && cr.card_back.present? }
      if refs.empty?
        redirect_back fallback_location: card_backoffice_profile_path(@profile),
          alert: "No card reference with image filenames for #{@profile.name}."
        return
      end

      FileUtils.mkdir_p(Catalog::CardReference::IMAGES_DIR)
      # CardReferences of one profile share the same front/back files, so render each unique file once.
      front_png = Grover.new(card_url_for(@profile, "front"), **grover_png_options).to_png
      back_png  = Grover.new(card_url_for(@profile, "back"), **grover_png_options).to_png

      refs.map(&:front_path).uniq.each { |p| File.binwrite(p, front_png) }
      refs.map(&:back_path).uniq.each  { |p| File.binwrite(p, back_png) }

      # Same version-bump rule as `rake cards:reversion`, applied to just this profile's refs so
      # the manifest advertises a new internal_version only when the rendered bytes actually change.
      refs.each(&:reversion!)

      versions = @profile.card_references.reload.map(&:internal_version).uniq.join(", ")
      redirect_to card_backoffice_profile_path(@profile),
        notice: "Rendered #{@profile.name} into the catalog (internal_version now #{versions})."
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

    def export_scope
      scope = params[:ids].present? ? Catalog::Profile.where(id: params[:ids]) : Catalog::Profile.all
      scope = scope.where(faction: params[:faction]) if params[:faction].present?
      sort_col = %w[name ducats].include?(params[:sort]) ? params[:sort] : "name"
      sort_dir = params[:dir] == "desc" ? "desc" : "asc"
      scope.order("#{sort_col} #{sort_dir}")
    end

    # Internal URL Grover's headless Chrome navigates to. Carries the render token so the
    # gated `card` action serves it without a Devise session (see BaseController).
    def card_url_for(profile, side)
      card_backoffice_profile_url(profile, host: request.base_url, side: side, render_token: BaseController.render_token)
    end

    def render_card_png(profile, side)
      Grover.new(card_url_for(profile, side), **grover_png_for_pdf_options).to_png
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
