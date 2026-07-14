module Backoffice
  # Shared exactly like weapons — see WeaponsController. A rule may be a plain rule or a unique
  # spell; when it is a spell the card prints it under the spell's name, so the rule's own name is
  # allowed to be blank in that case and in no other.
  class SpecialRulesController < BaseController
    before_action :set_special_rule, only: %i[edit update destroy]

    # GET /backoffice/special_rules
    def index
      @special_rules = Catalog::SpecialRule.order(:name)
      if params[:search].present?
        @special_rules = @special_rules.where("name ILIKE :q OR spell_name ILIKE :q", q: "%#{params[:search]}%")
      end
      @carried_by = Catalog::ProfileSpecialRule.group(:special_rule_id).count
    end

    # GET /backoffice/special_rules/new
    def new
      @special_rule = Catalog::SpecialRule.new
    end

    # POST /backoffice/special_rules
    #
    # Answers JSON as well, for the profile editor's inline "new special rule".
    def create
      @special_rule = Catalog::SpecialRule.new(special_rule_params)

      if @special_rule.save
        respond_to do |format|
          format.html { redirect_to backoffice_special_rules_path, notice: "Created #{display_name(@special_rule)}." }
          format.json { render json: { id: @special_rule.id, name: display_name(@special_rule) }, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @special_rule.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    # GET /backoffice/special_rules/:id/edit
    def edit
    end

    # PATCH /backoffice/special_rules/:id
    def update
      affected = @special_rule.cards_affected.count

      if @special_rule.update(special_rule_params)
        redirect_to backoffice_special_rules_path,
          notice: "Saved #{display_name(@special_rule)}. #{affected} card#{"s" unless affected == 1} now out of date."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /backoffice/special_rules/:id
    #
    # Only an orphaned rule may go — see WeaponsController#destroy for why the guard lives here.
    def destroy
      if @special_rule.profile_special_rules.exists?
        redirect_to backoffice_special_rules_path,
          alert: "#{display_name(@special_rule)} is still carried by #{@special_rule.profiles.count} profile(s) and cannot be deleted."
      else
        @special_rule.destroy
        redirect_to backoffice_special_rules_path, notice: "Deleted #{display_name(@special_rule)}."
      end
    end

    private

    def set_special_rule
      @special_rule = Catalog::SpecialRule.find(params.expect(:id))
    end

    # What to call a rule in a flash or a picker: a spell-only rule has no name of its own.
    def display_name(rule)
      rule.name.presence || rule.spell_name
    end
    helper_method :display_name

    def special_rule_params
      permitted = params.expect(special_rule: [
        :name, :description, :spell_name, :spell_cost, :spell_difficulty, :spell_description
      ])

      # The spell columns are nullable, and a blank field means "not a spell" — not zero.
      permitted.to_h.transform_values { |value| value.is_a?(String) ? value.strip : value }.tap do |attrs|
        %w[spell_name spell_cost spell_difficulty spell_description].each do |key|
          attrs[key] = nil if attrs[key].blank?
        end
      end
    end
  end
end
