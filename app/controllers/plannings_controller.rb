class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts]

  def index
    @plannings = Planning.all
    @roles = Role.all
    @users = User.all
    @slot_templates = Slot.slot_templates # liste des roles
  end

  def show
  end

  def skeleton
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
    # construire array de hash pour envoi vers JS calendar
    # => @slots_array_nice => as many items as slots with same start, end, role
    # => @slots_array => as many items as slots
    @slots_array_nice = []
    @slots_array = []
    @slots.each do |slot|
      nombre = count_people_on_slot(@slots, slot) # nb people sur le slot = slots avec même heure de début et de fin et role
        cpt = count_presence_in_array(@slots, slot) # si >0, le slot est déjà présent dans l'array
        a= {
              id:  slot.id,
              start:  slot.start_at,
              end: slot.end_at,
              title: Role.find_by_id(slot.role_id).name, # nom du role
              role_id: slot.role_id, # nom du role
              nombre: nombre, # nombre de users nécessaires au groupement de slots
              created_at: slot.created_at,
              updated_at: slot.updated_at,
              color: Role.find_by_id(slot.role_id).role_color
              }
        if cpt == 0
          # construire le NICE hash
          @slots_array_nice << a
        end
          # construire le BASIC hash
          @slots_array << a
  end
  @slots_array_nice.to_json
  @slots_array.to_json
end

  def users
    @users = User.all
  end

  def conflicts

  end

  def update
    @planning = Planning.find(params[:id])
    @planning.update(planning_params)
    @planning.save!
    redirect_to planning_users_path(@planning)
  end

  private

  def planning_params
    params.require(:planning).permit("user_ids" => [])
  end

  def set_planning
    @planning = Planning.find(params[:id])
  end

  def count_people_on_slot(slots, slot)
    nombre = 0
    slots.each do |s|
      if (s.start_at == slot.start_at and s.end_at == slot.end_at and s.role_id == slot.role_id)
        nombre += 1
      end
    end
    return nombre
  end

  def count_presence_in_array(slots, slot)
    # si cpt > 0, 1 slot similaire est déjà présent dans @slots_array_nice
      cpt = 0
      @slots_array_nice.each do |sl|
        if @slots_array_nice != []
          if sl != nil
            if (sl[:start].to_date == slot.start_at.to_date and sl[:start].hour == slot.start_at.hour and sl[:end].to_date == slot.end_at.to_date and sl[:role_id] == slot.role_id)
              # attention, je ne fais pas le matching sur les minutes
              cpt +=1
            end
          end
        end
      end
      return cpt
  end

end
