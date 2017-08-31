module PlanningHelper
  def planning_slide_class(planning)
    planning.status
  end

  def planning_slide_label(planning)
    case planning.status
    when :not_started
      "No Planning #{planning.week_number}"
    else
      "Week : #{planning.week_number}"
    end
  end

  def planning_link(planning)
    case planning.status
    when :not_started || :in_progress
      "link_to planning_skeleton_path(planning)"
    else
      "link_to planning_conflicts_path(planning)"
    end
  end
end
