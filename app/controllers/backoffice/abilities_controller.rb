# SPDX-License-Identifier: AGPL-3.0-or-later

module Backoffice
  # The rulebook's glossary of Character and Weapon Abilities (CARNEVALEB-86). Profiles and weapons
  # may only list abilities found here (validates_ability_glossary), so a card introducing a new one
  # starts by adding it on this page.
  class AbilitiesController < BaseController
    before_action :set_ability, only: %i[edit update destroy]
    before_action -> { set_history_for(@ability) }, only: %i[edit update]

    # GET /backoffice/abilities
    def index
      @category = Catalog::Ability::CATEGORIES.include?(params[:category]) ? params[:category] : "character"
      @abilities = Catalog::Ability.where(category: @category).order(:name)
      @abilities = @abilities.where("name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%") if params[:search].present?
      @usage = Catalog::Ability.usage_counts(@category)
    end

    # GET /backoffice/abilities/new
    #
    # Prefilled from the query string, which is how the profile and weapon editors link here when
    # they reject an ability the glossary does not know yet.
    def new
      @ability = Catalog::Ability.new(
        category: Catalog::Ability::CATEGORIES.include?(params[:category]) ? params[:category] : "character",
        name: Catalog::Ability.base_name(params[:name])
      )
    end

    # POST /backoffice/abilities
    def create
      @ability = Catalog::Ability.new(ability_params.merge(category: params.dig(:ability, :category)))

      if @ability.save
        redirect_to backoffice_abilities_path(category: @ability.category), notice: "Created #{@ability.name}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /backoffice/abilities/:id/edit
    def edit
    end

    # PATCH /backoffice/abilities/:id
    #
    # A rename rewrites every card listing the ability (Catalog::AbilityRename); the category is
    # fixed once created, since the cards listing it are of one kind.
    def update
      rewritten = Catalog::AbilityRename.call(@ability, ability_params[:name], ability_params.except(:name))
      notice = "Saved #{@ability.name}."
      if rewritten.any?
        notice += " Renamed on #{rewritten.size} #{rewritten.first.model_name.human.downcase.pluralize(rewritten.size)}; " \
                  "their cards are now out of date."
      end
      redirect_to backoffice_abilities_path(category: @ability.category), notice: notice
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages.each { |m| @ability.errors.add(:base, m) } unless e.record == @ability
      render :edit, status: :unprocessable_entity
    end

    # DELETE /backoffice/abilities/:id
    #
    # Only an ability no card lists may go: removing one in use would leave those cards failing
    # validation on their next save.
    def destroy
      carriers = @ability.carriers
      if carriers.any?
        redirect_to backoffice_abilities_path(category: @ability.category),
          alert: "#{@ability.name} is still listed by #{carriers.size} card(s) " \
                 "(#{carriers.first(5).map(&:name).to_sentence}) and cannot be deleted."
      else
        @ability.destroy!
        redirect_to backoffice_abilities_path(category: @ability.category), notice: "Deleted #{@ability.name}."
      end
    end

    private

    def set_ability
      @ability = Catalog::Ability.find(params.expect(:id))
    end

    def ability_params
      params.expect(ability: %i[name description])
    end
  end
end
