class SlotsController < ApplicationController
  before_action :set_planning_id, only: [:create, :new, :edit, :resolution, :update, :destroy]

  # rubocop:disable AbcSize, MethodLength
  # Too much assignment, condition and branching
  def create
    @slot = Slot.new(slot_params)
    @slot.planning = @planning
    @slots = @planning.slots
    @slot_templates = Slot.slot_templates
    @slot.user_id = User.find_by(first_name: 'no solution').id
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
  # rubocop:enable AbcSize, MethodLength

  def new
    @slot = Slot.new
  end

  def edit(*slot_id)
    puts slot_id
      @slot = Slot.find(slot_id)
      @user = User.find_by(user_id: @slot.user_id)

      @slot = Slot.find(params[:id])
      @user = User.find_by(first_name: 'jean')

  end

  # rubocop:disable AbcSize, MethodLength
  def resolution
    # idem que edit
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
    @slot = Slot.find(params[:id])
    respond_to do |format|
      if @slot.update(slot_params)
        format.html { redirect_to planning_skeleton_path(@planning) } # @slot
        format.js
        format.json { render json: @slot }
      else
        format.html { render :edit }
        format.js
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def destroy
    @slot = Slot.find(params[:id])
    @slot.destroy
    render json: @slot
  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :role_id, :user_id)
  end

  private

  def set_planning_id
    @planning = Planning.find(params[:planning_id])
  end
end
