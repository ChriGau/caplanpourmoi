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
    # @slot.planning = 21
    if @slot.save
      respond_to do |format|
      format.html { redirect_to planning_skeleton_path(@planning.id) }
      format.js  # <-- will render `app/views/shifts/edit.js.erb`
      end
    else
      respond_to do |format|
      format.html { render 'slots/edit' }
      format.js  # <-- idem
      end
    end
  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :role_id)
  end
end
