class SlotsController < ApplicationController
  before_action :set_planning_id, only: [:create, :new, :edit, :resolution, :update, :destroy]

  # rubocop:disable AbcSize, MethodLength
  # Too much assignment, condition and branching
  def create
    slot_model = Slot.new(slot_params)
    authorize slot_model
    user_id = User.find_by(first_name: 'no solution').id
    slot_list = []
    params[:nbemployees].to_i.times {slot_list << slot_model.dup}
    clicked_day = slot_params[:start_at].to_datetime.strftime("%u").to_i
    unless params[:items].nil?
      params[:items].each do |day|
        params[:nbemployees].to_i.times do
          new_slot = slot_model.dup
          new_slot.start_at = slot_model.start_at + (day.to_i - clicked_day).days
          new_slot.end_at = slot_model.end_at +  (day.to_i - clicked_day).days
          slot_list << new_slot
        end
      end
    end
    @slot = slot_model
    @slots = @planning.slots
    @slot_templates = Slot.slot_templates
    if @planning.slots << slot_list
      respond_to do |format|
        format.html { redirect_to planning_skeleton_path(@planning) }
        format.js
        format.json { render json: @slot }
      end
    else
      respond_to do |format|
        format.html
        @errors = slot_list.select{|s| s.errors.messages != nil}.first.errors.messages.values.flatten.join(" + ")
        format.js
        format.json { render json: @slot.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def new
    @slot = Slot.new
  end

  def edit
    @slot = Slot.find(params[:id])
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
        # do not respond to html format pk sinon on a 2 PATCH requests quand on
        # clique sur le bouton du form + déclenche l'event click du fullcalendar
        # format.html { redirect_to planning_skeleton_path(@planning) }
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
    @slot = Slot.destroy(params[:id])
    respond_to do |format|
      format.js  # <-- will render `app/views/slots/destroy.js.erb`
    end
  end

  def slot_params
    params.require(:slot).permit(:start_at, :end_at, :role_id)
  end

  private

  def set_planning_id
    @planning = Planning.find(params[:planning_id])
  end
end
