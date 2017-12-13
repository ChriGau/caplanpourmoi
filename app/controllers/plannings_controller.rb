# rubocop:disable Metrics/ClassLength
class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts, :events]

  # rubocop:disable AbcSize
  def index
    @plannings = Planning.all.order(:week_number)
    @roles = Role.all

    @users = User.where.not(first_name: 'no solution').includes(:roles).sort do |a, b|
      a.roles.first.name <=> b.roles.first.name
    end

    @slot_templates = Slot.slot_templates # liste des roles
  end
  # rubocop:enable AbcSize

  def show; end

  def skeleton
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
  end

  # rubocop:disable AbcSize, BlockLength, LineLength, MethodLength
  def conflicts
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles
    @url = 'conflicts'
    # variables pour fullcalendar
    @slots_array = []
    @slots_solution = []
    @user = current_user

    @slots.each do |slot|
      # Fake solution > def user id solution

      if !User.find(slot.user_id).profile_picture.nil?
        # picture du user
        picture = 'http://res.cloudinary.com/dksqsr3pd/image/upload/c_fill,r_60,w_60/' + User.find(slot.user_id).profile_picture.path
      else
        # point d'interrogation par defaut
        picture = 'http://a398.idata.over-blog.com/60x60/3/91/14/12/novembre-2010/point-d-interrogation-bleu-ciel.jpg'
      end

      a = {
        id:  slot.id,
        start:  slot.start_at,
        end: slot.end_at,
        title: Role.find_by(id: slot.role_id).name, # nom du role
        role_id: slot.role_id, # nom du role
        created_at: slot.created_at,
        updated_at: slot.updated_at,
        color: Role.find_by(id: slot.role_id).role_color,
        planning_id: slot.planning_id,
        user_id: User.find(slot.user_id).id,
        picture: picture
      }

      picture_solution = 'http://res.cloudinary.com/dksqsr3pd/image/upload/c_fill,r_60,w_60/' + User.find_by(first_name: 'jean').profile_picture.path
      user_id_solution = User.find_by(first_name: 'jean').id

      b = {
        id: slot.id,
        start: slot.start_at,
        end: slot.end_at,
        title: Role.find_by(id: slot.role_id).name, # nom du role
        role_id: slot.role_id, # nom du role
        created_at: slot.created_at,
        updated_at: slot.updated_at,
        color: Role.find_by(id: slot.role_id).role_color,
        planning_id: slot.planning_id,
        user_id: user_id_solution,
        picture: picture_solution
      }
      @slots_array << a
      @slots_solution << if slot.user_id == User.find_by(first_name: 'no solution').id
                           b
                         else
                           a
                         end
    end
    # Fake solution => le boss remplacera le no solution
    @user_solution = User.find_by(first_name: 'jean')

    demo_method(@planning) if @planning.week_number == 37

    # TODO : if no solution, generate solution calculation
    # => solution calculation
    calcul_v1 = CalculSolutionV1.new(@planning)
    calcul_v1.save

    # @calcul_results = { :calcul_arrays, :test_possibilities, :solutions_array, :best_solution, :calculation_abstract }
    @calcul_results = calcul_v1.perform
    # @calcul_arrays = { slotgroups_array: @slotgroups_array, slots_array: @slots_array }
    @calcul_arrays = @calcul_results[:calcul_arrays]
    @test_possibilities = @calcul_results[:test_possibilities]
    @solutions_array = @calcul_results[:solutions_array]
    @best_solution = @calcul_results[:best_solution]
    @calculation_abstract = @calcul_results[:calculation_abstract]
    flash[:notice] = message_calculation_notice
  end

  # rubocop:enable MethodLength

  def users
    @users = User.where.not(first_name: 'no solution').includes(:roles, :plannings, :teams).sort do |a, b|
      if a.plannings.include?(@planning) == b.plannings.include?(@planning)
        a.roles.first.name <=> b.roles.first.name
      elsif a.plannings.include?(@planning)
        -1
      else
        1
      end
    end
  end
  # rubocop:enable AbcSize, BlockLength, LineLength

  def update
    @planning = Planning.find(params[:id])
    @planning.update(planning_params)
    @planning.save!
    redirect_to planning_conflicts_path(@planning)
  end

  def events
    # json only request for fullcalendar
    # render events.json.jbuilder
  end

  private

  # rubocop:disable AbcSize, MethodLength
  def demo_method(planning)
    vendeur = Role.find_by(name: 'vendeur')
    barista = Role.find_by(name: 'barista')
    # useless
    s1 = planning.slots.where(user_id: nil).where(role_id: vendeur.id)[0]
    if !s1.nil? && s1.user.nil?
      s1.user = User.find_by(first_name: 'valentine')
      s1.save
    end

    s2 = planning.slots.where(user_id: nil).where(role_id: barista.id)[0]
    if !s2.nil? && s2.user.nil?
      s2.user = User.find_by(first_name: 'paul')
      s2.save
    end
    # added
    s = Slot.where(user_id: User.find_by(first_name: 'axel').id)
    s.each do |slot|
      slot.user_id = User.find_by(first_name: 'arielle').id
      slot.save!
    end
  end
  # rubocop:enable AbcSize, MethodLength

  def planning_params
    params.require(:planning).permit('user_ids' => [])
  end

  def set_planning
    @planning = Planning.find(params[:id])
  end

  def get_array_of_slotgroup_id(slots)
    # returns array of slotgroups_id assigned to an array of slots
    slotgroups = []
    slots.each do |slot|
      slotgroups << slot.slotgroup_id unless slot.slotgroup_id.nil?
    end
    slotgroups.uniq # get rid of duplicates
  end

  # rubocop:disable LineLength

  def message_calculation_notice
    pourcent = (@calculation_abstract[:nb_iterations].fdiv(@calculation_abstract[:nb_possibilities_theory]) * 100).round(2)
    "#{@calculation_abstract[:nb_solutions]} solutions trouvées,
    dont #{@calculation_abstract[:nb_optimal_solutions]} optimales.
     #{@calculation_abstract[:nb_iterations]} itérations effectuées parmi
    #{@calculation_abstract[:nb_possibilities_theory]} possibilités théoriques,
    soit #{pourcent}
     pourcents du champs balayé"
  end
end
# rubocop:enable Metrics/ClassLength
