# rubocop:disable Metrics/ClassLength
class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts, :events, :resultevents]

  # rubocop:disable AbcSize

  def index

    @plannings_list = plannings_list
    @roles = Role.all
    @users = User.where.not(first_name: 'no solution').includes(:roles).sort do |a, b|
      a.roles.first.name <=> b.roles.first.name
    end

    @slot_templates = Slot.slot_templates # liste des roles
  end
  # rubocop:enable AbcSize

  def show; end

  def create
    @planning = Planning.new(week_number: params[:week_number], year: params[:year_number])
    if @planning.save
      redirect_to planning_skeleton_path(@planning)
    end
  end

  def skeleton
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles (Array)
  end

  # rubocop:disable AbcSize, BlockLength, LineLength, MethodLength
  def conflicts
    @planning = Planning.find(params[:id])
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @slot_templates = Slot.slot_templates # liste des roles (Array)
    @url = 'conflicts'
    # variables pour fullcalendar
    @slots_array = []
    @slots_solution = []
    @user = current_user

    # Fake solution => le boss remplacera le no solution
    @user_solution = User.find_by(first_name: 'jean')
    demo_method(@planning) if @planning.week_number == 37

    if !@planning.solutions.exists?
      flash.now[:alert] = "Générez des solutions pour votre planning"
    elsif !@planning.solutions.chosen.exists?
      flash.now[:alert] = "Validez une solution pour votre planning"
    end
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
    compute_solutions = ComputeSolution.create(planning_id: @planning.id)
    ComputePlanningSolutionsJob.perform_later(@planning, compute_solutions)
    redirect_to planning_compute_solutions_path(@planning)

  end

  def events
    # json only request for fullcalendar
    # render events.json.jbuilder
  end

  def resultevents
    # renders resultevents.json.jbuilder
  end

  private

  def plannings_list
    current_week_number = Time.now.strftime('%U').to_i
    current_year_number = Date.today.strftime('%Y').to_i
    ((current_week_number - 49)..(current_week_number + 50)).to_a.map do |week_number|
      if week_number <= 0
        year = current_year_number - 1
        week_number = 52 + week_number
      elsif week_number <= 52
        year = current_year_number
        week_number = week_number
      else
        year = current_year_number + 1
        week_number = (week_number - 52)
      end
      planning = Planning.find_by(year: year, week_number: week_number)
      {year: year, week_number: week_number, planning: planning}
    end
  end

  # rubocop:disable AbcSize, MethodLength
  def demo_method(planning)
    vendeur = Role.find_by(name: 'vendeur')
    barista = Role.find_by(name: 'barista')
    # useless
    # sélectionner le slots pour lesquels user_id = nil + role_id = vendeur.id
    s1 = planning.slots.select{|x| x.get_associated_chosen_solution_slot.user == nil && x.role_id == vendeur.id }.first
    # remplacer le user de ce slot par 'valentine'
    if !s1.nil? && s1.user.nil?
      s1.get_associated_chosen_solution_slot.user = User.find_by(first_name: 'valentine')
      s1.get_associated_chosen_solution_slot.save
    end

    # sélectionner le slots pour lesquels user_id = nil + role_id = barista.id
    s2 = planning.slots.select{|x| x.get_associated_chosen_solution_slot.user == nil && x.role_id == barista.id }.first
    if !s2.nil? && s2.user.nil?
      s2.get_associated_chosen_solution_slot.user = User.find_by(first_name: 'paul')
      s2.get_associated_chosen_solution_slot.save
    end

    # get slots where user_id == axel
    s = Slot.select{|x| x.get_associated_chosen_solution_slot.user == User.find_by(first_name: 'axel') }
    s.each do |slot|
      slot.get_associated_chosen_solution_slot.user = User.find_by(first_name: 'arielle')
      slot.get_associated_chosen_solution_slot.save!
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

end
# rubocop:enable Metrics/ClassLength
