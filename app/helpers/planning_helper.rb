module PlanningHelper
  def planning_slide_class(planning)
    planning.status
  end

  def planning_slide_label(planning)
    case planning.status.to_sym
    when :not_started
      "S#{planning.week_number}"
    else
      "S#{planning.week_number}"
    end
  end

  def planning_link(planning)
    case planning.status.to_sym
    when :not_started, :in_progress
      link_to planning_slide_label(planning), planning_skeleton_path(planning)
    else
      link_to planning_slide_label(planning), planning_conflicts_path(planning)
    end
  end

  def parse_week_number(planning)
    week_start = Date.commercial(2017, planning.week_number, 1).strftime('%d/%m/%y')
    week_end = Date.commercial(2017, planning.week_number, 7).strftime('%d/%m/%y')
    "Du #{week_start} au #{week_end}"
  end

  def planning_count_people_on_similar_slot(planning, slot)
    planning.slots.count { |s|
      s.start_at == slot.start_at &&
        s.end_at == slot.end_at &&
        s.role_id == slot.role_id
    }
  end
end
