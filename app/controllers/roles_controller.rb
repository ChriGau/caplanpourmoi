class RolesController < ApplicationController
  before_action :set_role, only: [:edit, :update, :destroy]
  def index
    @list = Role.all
    @role = Role.new
  end

  def new
    @role = Role.new
    authorize @role
    # colors not yet chosen for a role
    @color_collection = Color.all.map(&:id) - Role.all.map(&:color_id).uniq
    @color = Color.new
  end

  def create
    # if colors does not exist
    if Color.find_by(hexadecimal_code: params["hexadecimal_code"].upcase).nil?
      # /!\ not elegant, a controller should only instanciate 1 object :/
      @color = Color.create(hexadecimal_code: params["hexadecimal_code"].upcase)
    end
    @color_id = Color.find_by(hexadecimal_code: params["hexadecimal_code"].upcase).id
    @role = Role.new(color_id: @color_id, name: params_role["name"])
    authorize @role
    if @role.save
      redirect_to plannings_path
    else
      render :new
    end
  end

  def edit
    authorize @role
    @color_collection = Color.all.map(&:id) - Role.all.map(&:color_id).uniq
  end

  def update
    # create color if color does not exist
    if params["hexadecimal_code"] != "#000000" && Color.find_by(hexadecimal_code: params["hexadecimal_code"]).nil?
      @color = Color.create(hexadecimal_code: params["hexadecimal_code"].upcase)
      color_id = @color.id
    elsif !Color.find_by(hexadecimal_code: params["hexadecimal_code"]).nil? # color is updated but already exists
      color_id = Color.find_by(hexadecimal_code: params["hexadecimal_code"]).id
    else # color is not updated
      color_id = @role.color.id
    end
    if @role.update(name: params_role[:name], color_id: color_id)
      redirect_to plannings_path
    else
      render :new
    end
  end

  def destroy
    if @role.users.empty? && @role.slots.empty? && @role.solution_slots.empty?
      if @role.destroy
        redirect_to plannings_path
      end
    else
      flash[:notice] = 'Impossible de supprimer le role - dépendances'
      redirect_to plannings_path
    end
  end

  private

  def set_role
    @role = Role.find(params[:id])
    authorize @role
  end

  def params_role
    params.require(:role).permit(:name, :intermediate, :color_id)
  end
end


