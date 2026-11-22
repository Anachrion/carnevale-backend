# SPDX-License-Identifier: AGPL-3.0-or-later

module Backoffice
  # The magic spells of the five Disciplines (CARNEVALEB-86). The Disciplines themselves are fixed
  # (Catalog::Spell::DISCIPLINES, mirrored in the app), so a new one remains developer work.
  class SpellsController < BaseController
    before_action :set_spell, only: %i[edit update destroy]
    before_action -> { set_history_for(@spell) }, only: %i[edit update]

    # GET /backoffice/spells
    def index
      @spells = Catalog::Spell.order(:discipline, cantrip: :desc, name: :asc)
      @spells = @spells.where("name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%") if params[:search].present?
      @chosen = Gang::EntrySpell.group(:spell_id).count
      @granted = Catalog::ProfileGrantedSpell.where.not(spell_id: nil).group(:spell_id).count
    end

    # GET /backoffice/spells/new
    def new
      @spell = Catalog::Spell.new(discipline: params[:discipline].presence_in(Catalog::Spell::DISCIPLINES))
    end

    # POST /backoffice/spells
    def create
      @spell = Catalog::Spell.new(spell_params)

      if @spell.save
        redirect_to backoffice_spells_path, notice: "Created #{@spell.name}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /backoffice/spells/:id/edit
    def edit
    end

    # PATCH /backoffice/spells/:id
    def update
      if @spell.update(spell_params)
        redirect_to backoffice_spells_path, notice: "Saved #{@spell.name}."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /backoffice/spells/:id
    #
    # Only a spell nobody uses may go: gangs that chose it are player data, and a profile granted it
    # would lose the grant.
    def destroy
      if @spell.in_use?
        redirect_to backoffice_spells_path, alert: in_use_message
      else
        @spell.destroy!
        redirect_to backoffice_spells_path, notice: "Deleted #{@spell.name}."
      end
    rescue ActiveRecord::InvalidForeignKey
      # Chosen or granted between the check and the delete; the foreign key held (B-33 TOCTOU).
      redirect_to backoffice_spells_path, alert: in_use_message
    end

    private

    def set_spell
      @spell = Catalog::Spell.find(params.expect(:id))
    end

    def spell_params
      params.expect(spell: %i[name discipline cost difficulty description cantrip])
    end

    def in_use_message
      "#{@spell.name} is chosen in #{@spell.entry_spells.count} gang(s) and granted by " \
        "#{@spell.profile_granted_spells.count} profile(s), so it cannot be deleted."
    end
  end
end
