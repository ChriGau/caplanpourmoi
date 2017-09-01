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
        format.js
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
end
