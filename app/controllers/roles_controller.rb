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
      # /!\ not elegant, a controller should only instanciate 1 object :/
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
    @color_collection = Color.all.map(&:id) - Role.all.map(&:color_id).uniq
  end

  def update
    @role = Role.find(params[:id])
    @old_name = @role.name
    # create color if color does not exist
    if Color.find_by(hexadecimal_code: params_role[:intermediate]).nil?
      # /!\ not elegant, a controller should only instanciate 1 object
      @color = Color.create(hexadecimal_code: params_role[:intermediate])
    end
    @color_id = Color.find_by(hexadecimal_code: params_role[:intermediate].upcase).id
    # if name is updated, we need to update all elements relating on the role name
    # --> the p_nb_hours_roles which belongs to ComputeSolution
    if @old_name != params_role[:name]
      list_comp_sol_to_update = ComputeSolution.select{|x| x.p_nb_hours_roles.has_key?(@old_name.to_sym)}
      list_comp_sol_to_update.each do |compute_solution|
        # replace old key by new key
        p_nb_hours_roles = compute_solution.p_nb_hours_roles
        p_nb_hours_roles[params_role[:name].to_sym] = p_nb_hours_roles.delete @old_name.to_sym
        compute_solution.save!
      end
    end
    if @role.update(name: params_role[:name], intermediate: params_role[:intermediate].upcase, color_id: @color_id)
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
