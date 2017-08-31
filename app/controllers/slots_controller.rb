class SlotsController < ApplicationController

  def create
    @slot = Slot.new(slot_params)
    @planning = Planning.find(params[:planning_id])
    @slot.planning = @planning
    @slots = @planning.slots
    @slot_templates = Slot.slot_templates

    if @slot.save
      redirect_to planning_skeleton_path(@planning), notice: "nouveau slot ajouté"
    else
      render 'plannings/skeleton'
    end

  end

  def edit
    @planning = Planning.find(params[:planning_id])
    @slot = Slot.find(params[:id])
    if @slot.save
      respond_to do |format|
        format.html { redirect_to planning_skeleton_path(@planning) }
        format.js
        format.json { render json: @slot }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.js
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @planning = Planning.find(params[:planning_id])
    @slot = Slot.find(params[:id])


    respond_to do |format|
      if @slot.update(slot_params)
        format.html { redirect_to planning_skeleton_path(@planning) } #@slot
        format.js { set_slots_json }
        format.json { render json: @slot }

      else
        format.html { render :edit }
        format.js
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :role_id)
  end

  def set_slots_json
   @slots = @planning.slots.order(:id)
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
                color: Role.find_by_id(slot.role_id).role_color,
                planning_id: slot.planning_id
              }
              if cpt == 0
            # construire le NICE hash
            @slots_array_nice << a
          end
            # construire le BASIC hash
            @slots_array << a
          end
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
