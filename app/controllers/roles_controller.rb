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
    if Color.find_by(hexadecimal_code: params_role["intermediate"]).nil?
      # create a new color /!\ not elegant, a controller should only instanciate 1 object :/
      @color = Color.create(hexadecimal_code: params_role["intermediate"])
    end
    @color_id = Color.find_by(hexadecimal_code: params_role["intermediate"]).id
    @role = Role.new(color_id: @color_id, name: params_role["name"])
    if @role.save
      redirect_to plannings_path
    else
      render :new
    end

  end

  def edit
    @role = Role.find(params[:id])
    @role.color = @role.color
    @color_collection = Color.all.map(&:name_fr)
  end

  def update
    @role = Role.find(params[:id])
    # color_role needs to be the hexadecimal color code VS color name_fr
    if params_role[:role_color].empty?
      @role.role_color = @role.role_color
    else
      color_hexadecimal = Role.color_list.select{ |k,v| v[:name_fr] == params_role[:role_color] }.values.first[:code]
      @role.role_color = color_hexadecimal
    end
    @role.name = params_role[:name]
    if @role.save
      redirect_to plannings_path, notice: 'Le role a été modifié'
    else
      render :update
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
    params.require(:role).permit(:name, :intermediate)
  end
end
