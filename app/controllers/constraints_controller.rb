class ConstraintsController < ApplicationController


  def show
  end

  def new
    @constraint = Constraint.new
  end

  # rubocop:disable AbcSize, MethodLength
  def create
    @user = User.find(params[:user_id])
    constraint_model = Constraint.new(constraint_params)
    constraint_model.update(user_id: @user.id, category: params[:category].first.to_i)
    constraint_list = []
    @constraints
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
        format.html { redirect_to user_path(@user) }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.js
      end
    end
  end

  def update
    @constraint = Constraint.find(params[:id])
    @user = User.find(params[:user_id])
    respond_to do |format|
      if @constraint.update(constraint_params)
        format.js
        format.json { render json: @constraint }
      else
        format.html { render :edit }
        format.js
        format.json { render json: @constraint.errors, status: :unprocessable_entity }
      end
    end
  end

  # rubocop:enable AbcSize, MethodLength

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
