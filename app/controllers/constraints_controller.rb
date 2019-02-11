class ConstraintsController < ApplicationController
  before_action :set_user, only: [:create, :events]
  before_action :set_constraint, only: [:destroy, :update]

  def show
  end

  def new
    @constraint = Constraint.new
  end

  # rubocop:disable AbcSize, MethodLength
  def create
    constraint_model = Constraint.new(constraint_params)
    constraint_model.attributes = {user_id: @user.id, category: params[:category].first.to_i}
    authorize constraint_model
    constraint_model.save
    constraint_list = []
    # @constraints
    clicked_day = constraint_params[:start_at].to_datetime.strftime("%u").to_i
    if !params[:items].nil?
      params[:items].each do |day|
          new_constraint = constraint_model.dup
          new_constraint.start_at = constraint_model.start_at + (day.to_i - clicked_day).days
          new_constraint.end_at = constraint_model.end_at +  (day.to_i - clicked_day).days
          constraint_list << new_constraint
      end
    else
      constraint_list << constraint_model
    end
    @constraints = @user.constraints
    if @user.constraints << constraint_list
      respond_to do |format|
        format.js { @constraints }
        format.html { redirect_to user_path(@user) }
      end
    else
      respond_to do |format|
        @errors = constraint_list.select{|s| s.errors.messages != nil}.first.errors.messages.values.flatten.join(" + ")
        @constraint = Constraint.new
        format.js
        format.html
      end
    end
  end

  def update
    authorize @constraint
    if @constraint.update(constraint_params)
      respond_to do |format|
        format.js
        format.json { render json: @constraint }
      end
    else
      respond_to do |format|
        format.js
        format.json { render json: @constraint.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @constraint
    @constraint.destroy
    respond_to do |format|
      format.js  # <-- will render `app/views/constraints/destroy.js.erb`
    end
  end

  # rubocop:enable AbcSize, MethodLength
  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_constraint
    @constraint = Constraint.find(params[:id])
  end

  def constraint_params
    params.require(:constraint).permit(:start_at, :end_at, :user_id, :category)
  end

  def get_constraints_array(constraints)
    array = []
    constraints.each do |constraint|
      a = {
        id:  constraint.id,
        start:  constraint.start_at,
        end: constraint.end_at,
        title: constraint.category,
        user_id: constraint.user_id
      }
      array << a
    end
    array
  end
end
