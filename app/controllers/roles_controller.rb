class RolesController < ApplicationController
  def new
    @role = Role.new
    @color_collection = []
    Role.color_list.each { |key,value| @color_collection << value[:name_fr] }
  end

  def create
    @role = Role.new(params_role)
    if @role.save
      redirect_to plannings_path, notice: "un nouveau role a été ajouté"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def params_role
    params.require(:role).permit(:name, :role_color)

  end
end
