module PlanningHelper
  def planning_slide_class(planning)
    planning.status
  end

  def planning_slide_label(week_number)
    "S#{week_number}"
  end

  def planning_status_label(planning)
    case planning.status.to_sym
    when :not_started
      '(Aucun Planning)'
    when :in_progress
      '(En cours)'
    when :complete
      '(Validé)'
    else
      '(Incomplet)'
    end
  end

  def planning_link(planning, week_number)
    if planning.nil?
      link_to planning_slide_label(week_number), plannings_path(alert: "Planning pas fini, Allez grouille toi patron")
    else
      if current_user.is_owner
        case planning.status.to_sym
          when :not_started, :in_progress
            link_to planning_slide_label(week_number), planning_skeleton_path(planning)
          else
          link_to planning_slide_label(week_number), planning_conflicts_path(planning)
        end
      elsif planning.chosen_solution.nil?
        link_to planning_slide_label(week_number), "#"
      else
        link_to planning_slide_label(week_number), planning_solution_path(id: planning.chosen_solution.id, planning_id: planning.id)
      end

    end
  end

  def parse_week_number(week_number, year_number)
    week_start = Date.commercial(year_number, week_number, 1).strftime('%d/%m')
    week_end = Date.commercial(year_number, week_number, 7).strftime('%d/%m')
    "Du #{week_start} au #{week_end}"
  end

  def planning_count_people_on_similar_slot(planning, slot)
    planning.slots.count do |s|
      s.start_at == slot.start_at &&
        s.end_at == slot.end_at &&
        s.role_id == slot.role_id
    end
  end

end
