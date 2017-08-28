class SlotsController < ApplicationController

  def create
    @slot = Slot.new(slot_params)
    @planning = Planning.find(params[:planning_id])
    @slot.planning = @planning
    @slot.user = current_user


    if @slot.save
      redirect_to planning_path(@planning), notice: "nouveau slot ajouté"
    else
      render 'plannings/show'
    end

  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :role_id)
  end
end
