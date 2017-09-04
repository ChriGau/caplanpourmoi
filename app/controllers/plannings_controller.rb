class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts, :events]

  def index
    @plannings = Planning.all.order(:week_number)
    @roles = Role.all
    @users = User.where.not(first_name: "no solution")
    @slot_templates = Slot.slot_templates # liste des roles
  end

  def show
  end

  def skeleton
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
    @url = "skeleton"
  end

  def conflicts
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
    # modifier 1 slot mécano du  mercredi 13/9 en "no solution"
    # guersbru : le dit slot n'a pas toujours l'id 887... ça crash je commente la ligne
    # Slot.find(887).user_id = "no solution"
    @url = "conflicts"
    # variables pour fullcalendar
    @slots_array = []
    @slots_solution = []
    @user = current_user
    @jean_id == User.find_by_first_name("jean").id

    @slots.each do |slot|
    # Fake solution > def user id solution

       if  User.find(slot.user_id).profile_picture != nil
        # picture du user
        picture = "http://res.cloudinary.com/dksqsr3pd/image/upload/c_fill,r_60,w_60/" + User.find(slot.user_id).profile_picture.path
      else
        # point d'interrogation par defaut
        picture = "http://a398.idata.over-blog.com/60x60/3/91/14/12/novembre-2010/point-d-interrogation-bleu-ciel.jpg"
      end

      a = {
        id:  slot.id,
        start:  slot.start_at,
        end: slot.end_at,
        title: Role.find_by_id(slot.role_id).name, # nom du role
        role_id: slot.role_id, # nom du role
        created_at: slot.created_at,
        updated_at: slot.updated_at,
        color: Role.find_by_id(slot.role_id).role_color,
        planning_id: slot.planning_id,
        user_id: User.find(slot.user_id).id,
        picture: picture
         }

        picture_solution = "http://res.cloudinary.com/dksqsr3pd/image/upload/c_fill,r_60,w_60/" + User.find_by_first_name("jean").profile_picture.path
        user_id_solution = User.find_by_first_name("jean").id

         b = {
        id:  slot.id,
        start:  slot.start_at,
        end: slot.end_at,
        title: Role.find_by_id(slot.role_id).name, # nom du role
        role_id: slot.role_id, # nom du role
        created_at: slot.created_at,
        updated_at: slot.updated_at,
        color: Role.find_by_id(slot.role_id).role_color,
        planning_id: slot.planning_id,
        user_id: user_id_solution,
        picture: picture_solution
         }
        @slots_array << a



        if slot.user_id == User.find_by_first_name("no solution").id
          @slots_solution << b
        else
          @slots_solution << a
        end
      end
      # Fake solution => le boss remplacera le no solution
      @user_solution = User.find_by_first_name("jean")
  end

  def users
    @users = User.all
    @url = "users"
  end

  def update
    @planning = Planning.find(params[:id])
    @planning.update(planning_params)
    @planning.save!
    redirect_to planning_users_path(@planning)
  end


  def events
    # json only request for fullcalendar
    # render events.json.jbuilder
  end

  private

  def planning_params
    params.require(:planning).permit("user_ids" => [])
  end

  def set_planning
    @planning = Planning.find(params[:id])
  end
end
