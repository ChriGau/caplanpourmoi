class RolesController < ApplicationController
  def index
    @list = Role.all
    @role = Role.new
  end

  def new
    @role = Role.new
    # colors not yet chosen for a role
    @color_collection = Color.all.map(&:id) - Role.all.map(&:color_id).uniq
    @color = Color.new
  end

  def create
    # if colors does not exist
    if Color.find_by(hexadecimal_code: params["hexadecimal_code"]).nil?
      # /!\ not elegant, a controller should only instanciate 1 object :/
      @color = Color.create(hexadecimal_code: params["hexadecimal_code"].upcase)
    end
    @color_id = Color.find_by(hexadecimal_code: params["hexadecimal_code"]).id
    @role = Role.new(color_id: @color_id, name: params_role["name"])
    if @role.save
      redirect_to plannings_path
    else
      render :new
    end
  end

  def edit
    @role = Role.find(params[:id])
    @color_collection = Color.all.map(&:id) - Role.all.map(&:color_id).uniq
  end

  def update
    @role = Role.find(params[:id])
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
    @role = Role.find(params[:id])
    if !@role.role_users.count.positive?
      if @role.destroy
        redirect_to plannings_path
      else
        flash[:error] = 'Impossible de supprimer le role - dépendances'
        redirect_to plannings_path
      end
    end
  end

  private

  def params_role
    params.require(:role).permit(:name, :intermediate, :color_id)
  end
end


