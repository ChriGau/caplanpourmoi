# rubocop:disable Metrics/ClassLength
class PlanningsController < ApplicationController
  before_action :set_planning, only: [:skeleton, :users, :conflicts, :events,
                                      :resultevents, :update, :use_template]
  skip_before_action :authenticate_user!, only: :ical

  # rubocop:disable AbcSize

  def index
    company_plannings = policy_scope(Planning)
    @plannings_list = plannings_list(company_plannings)
    authorize Planning
    @roles = Role.all
    @users = User.active.includes(:roles).sort do |a, b|
      a.roles.empty? || b.roles.empty? ? 1 : a.roles.first&.name <=> b.roles.first&.name
    end

    @slot_templates = Slot.slot_templates # liste des roles
    flash[:alert] = params[:alert] if params[:alert]

  end
  # rubocop:enable AbcSize

  def show; end

  def create
    @planning = Planning.new(week_number: params[:week_number], year: params[:year_number])
    authorize @planning
    if @planning.save
      redirect_to planning_skeleton_path(@planning)
    end
  end

  def skeleton
    @slots = @planning.slots.order(:id)
    @slot = Slot.new
    @roles = Role.all
    # @slot_templates = Slot.slot_templates
    # plannings qui ont des slots, utilisés pour use_template
    @plannings = Planning.select{ |p| p.slots.count.positive? }.sort_by{ |p| p.start_date }.reverse.last(30)
    authorize @planning
  end

  # rubocop:disable AbcSize, BlockLength, LineLength, MethodLength
  def conflicts
    authorize @planning
    @solution = @planning.solutions.chosen.first
    @roles = Role.all
    @url = 'conflicts'
    # variables pour fullcalendar

    if !@planning.solutions.exists?
      flash[:alert] = I18n.t 'planning.no_planning_solution'
      redirect_to planning_skeleton_path(@planning)
    elsif !@planning.solutions.chosen.exists?
      redirect_to planning_compute_solutions_path(@planning)
    end

    @solution_slot = SolutionSlot.first # to be used in _reaffect_slot_form.html.erb
  end

  # rubocop:enable MethodLength

  def users
    authorize @planning
    # go back to skeleton if no slot created
    if @planning.slots.count.positive?
      @users = User.where.not(first_name: 'no solution').includes(:roles, :plannings, :teams).sort do |a, b|
        if a.plannings.include?(@planning) == b.plannings.include?(@planning)
          a.roles.first.name <=> b.roles.first.name
        elsif a.plannings.include?(@planning)
          -1
        else
          1
        end
      end
    else
      redirect_to planning_skeleton_path(@planning), alert: "Ajoutez des créneaux à votre planning"
    end
  end
  # rubocop:enable AbcSize, BlockLength, LineLength

  def update
    authorize @planning
    # go back to skeleton if no slots created
    if !@planning.slots.count.positive?
      redirect_to planning_skeleton_path(@planning), alert: "Ajoutez des créneaux à votre planning"
      # need users to save planning and go find a solution
      # user_ids are part of params => { {...}, {"planning"=> "user_ids" => [] } }
    elsif params.keys.include?("planning")
      @planning.update(planning_params)
      @planning.save!
      # Timestamp #1 : creation du ComputeSolution
      t1 = ["t1", Time.now]
      compute_solutions = ComputeSolution.create(planning_id: @planning.id)
      compute_solutions.update(timestamps_algo: [t1])
      ComputePlanningSolutionsJob.perform_later(@planning, compute_solutions)
      redirect_to planning_compute_solutions_path(@planning)
    else # can't save planning and go find a solution if no user(s)
      redirect_to planning_users_path(@planning), alert: "Sélectionnez des users"
    end
  end

  def events
    # json only request for fullcalendar
    # render events.json.jbuilder
    authorize @planning
  end

  def resultevents
    authorize @planning
    @solution = Solution.find(params[:solution_id])
    # renders resultevents.json.jbuilder
  end

  def use_template
    authorize @planning
    template = Planning.find(params[:planning_id]) #planning_copied
    gap = gap_in_days_between_two_dates(@planning.start_date, template.start_date)
    template.slots.each do |slot|
      Slot.create!(
        planning_id: @planning.id,
        start_at: slot.start_at += gap.days,
        end_at: slot.end_at += gap.days,
        role_id: slot.role.id,
      )
    end
  redirect_to planning_skeleton_path
  end

  def ical
    skip_authorization
    @user = User.find_by(key: params[:key]) || false
    raise Exception.new("this calendar doesn't exist") if !@user || params[:key].nil?

    @slots = SolutionSlot.where(user_id: @user)
                         .joins(:solution)
                         .where(solutions: { effectivity: 'chosen' })
                         .map(&:slot)
                         .sort_by(&:start_at)

    slots_month_groups = @slots.group_by { |slot| slot.start_at.strftime('%m') }
    slots_week_groups = @slots.group_by { |slot| slot.start_at.strftime('%U') }

    respond_to do |format|
      format.ics do
        cal = Icalendar::Calendar.new
        name = "#{@user.first_name}"
        cal.x_wr_calname = "Ecomotive de #{@user.first_name.capitalize}"
        @slots.each_with_index do |slot, index|
          month_slots = slots_month_groups[slot.start_at.strftime('%m')]
          week_slots = slots_week_groups[slot.start_at.strftime('%U')]
          total_month = month_slots.map(&:length).reduce(:+)
          total_week = week_slots.map(&:length).reduce(:+)
          index = month_slots.index(slot)
          hours_worked = month_slots.slice(0, index + 1).map(&:length).reduce(:+)
          cal.event do |e|
            e.dtstart     = slot.start_at
            e.dtend       = slot.end_at
            e.summary     = "#{slot.role.name} ##{slot.length/3600}h/#{total_week/3600}h cette semaine"
            e.description = "Ce moi ci:\nTotal travaillé / Total à travailler :\n#{hours_worked/3600}h / #{total_month/3600}h\n"
          end
        end
        cal.publish
        render plain: cal.to_ical
      end
      format.html do
      end
    end
  end

  private

  def plannings_list(company_plannings)
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
      planning = company_plannings.find_by(year: year, week_number: week_number)
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

  def gap_in_days_between_two_dates(date1, date2)
    # => gap in days, integer (>0 id date2 < date1)
    (date1 - date2).to_i
  end
end
# rubocop:enable Metrics/ClassLength
