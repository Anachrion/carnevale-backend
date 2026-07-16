module Backoffice
  # Weapons are shared across the catalog — one "Stiletto" row, carried by every profile that
  # fights with one — so they are edited here, in their own right, rather than inside a profile.
  # Editing one is therefore a catalog-wide edit: every card carrying it is out of date afterwards,
  # which the publish page reports without being told (a card's fingerprint covers its weapons).
  class WeaponsController < BaseController
    before_action :set_weapon, only: %i[edit update destroy]

    # GET /backoffice/weapons
    def index
      @weapons = Catalog::Weapon.order(:name)
      @weapons = @weapons.where("name ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%") if params[:search].present?
      @carried_by = Catalog::ProfileWeapon.group(:weapon_id).count
    end

    # GET /backoffice/weapons/new
    def new
      @weapon = Catalog::Weapon.new
    end

    # POST /backoffice/weapons
    #
    # Answers JSON as well, which is how the profile editor invents a weapon without leaving the
    # card it is in the middle of authoring.
    def create
      @weapon = Catalog::Weapon.new(weapon_params)

      if @weapon.save
        respond_to do |format|
          format.html { redirect_to backoffice_weapons_path, notice: "Created #{@weapon.name}." }
          format.json { render json: { id: @weapon.id, name: @weapon.name }, status: :created }
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @weapon.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    # GET /backoffice/weapons/:id/edit
    def edit
    end

    # PATCH /backoffice/weapons/:id
    def update
      # Counted before the save: these are the cards this edit is about to invalidate.
      affected = @weapon.cards_affected.count

      if @weapon.update(weapon_params)
        redirect_to backoffice_weapons_path,
          notice: "Saved #{@weapon.name}. #{affected} card#{"s" unless affected == 1} now out of date."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /backoffice/weapons/:id
    #
    # Only an orphaned weapon may go — one no profile carries. Destroying a carried weapon would
    # strip it off every card printing it, so the guard is here, not only on the hidden button: a
    # direct request cannot get past it either.
    def destroy
      if @weapon.profile_weapons.exists?
        redirect_to backoffice_weapons_path,
          alert: "#{@weapon.name} is still carried by #{@weapon.profiles.count} profile(s) and cannot be deleted."
      else
        @weapon.destroy!
        redirect_to backoffice_weapons_path, notice: "Deleted #{@weapon.name}."
      end
    rescue ActiveRecord::InvalidForeignKey
      # A profile attached this weapon between the exists? check and the delete — the FK saved the
      # integrity; show the same friendly alert instead of a 500 (B-33 TOCTOU).
      redirect_to backoffice_weapons_path,
        alert: "#{@weapon.name} is still carried by a profile and cannot be deleted."
    end

    private

    def set_weapon
      @weapon = Catalog::Weapon.find(params.expect(:id))
    end

    def weapon_params
      permitted = params.expect(weapon: [ :name, :damage, :evasion, :penetration, :range, :abilities_text ])

      permitted
        .except(:abilities_text)
        .to_h
        .merge(abilities: text_to_list(permitted[:abilities_text]))
    end
  end
end
