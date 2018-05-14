# rubocop:disable Metrics/ClassLength
class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts, :events, :resultevents]

  # rubocop:disable AbcSize

  def index
    @plannings_list = plannings_list
    @roles = Role.all
    @users = User.where.not(first_name: 'no solution').includes(:roles).sort do |a, b|
      a.roles.empty? || b.roles.empty? ? 1 : a.roles.first&.name <=> b.roles.first&.name
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
    @solution = @planning.solutions.chosen.first
    @slot_templates = Slot.slot_templates # liste des roles (Array)
    @url = 'conflicts'
    # variables pour fullcalendar

    if !@planning.solutions.exists?
      flash.now[:alert] = "Générez des solutions pour votre planning"
    elsif !@planning.solutions.chosen.exists?
      flash.now[:alert] = "Validez une solution pour votre planning"
    end
    @solution_slot = SolutionSlot.find(25603) # to be used in _reaffect_slot_form.html.erb
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
    @solution = Solution.find(params[:solution_id])
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
