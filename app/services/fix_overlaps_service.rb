# all solution_slots are created according to GoFindSolutionsService output
# but, these solution_slots might contain overlaps => we need to fix them
# overlap = 1 user is at more than one place at once
# <=> is assigned to more than one solution_slot(s) which overlap

# rubocop:disable LineLength, MethodLength, ClassLength

class FixOverlapsService
  attr_accessor :slots_array

  def initialize(compute_solution, slotgroups_array)
    @compute_solution = compute_solution
    @slotgroups_array = slotgroups_array
  end

  # rubocop:disable AbcSize

  def perform
    # régler les pbs d'overlap pour chaque solution
    @compute_solution.solutions.each do |solution|
      # pour les solutions qui ont des overlaps
      unless solution.nb_overlaps.zero?
        # choper les informations sur les overlaps => [ {:solution_slot_id, :solution_slot_overlapped_id}, {...} ]
        overlaps_information = get_overlaps_information(solution, @slotgroups_array)
        # sur chaque slot en overlap
        overlaps_information.each do |overlap_info|
          # user affecté au slot est no solution? = overlap réglé = skip
          next if SolutionSlot.find(overlap_info[:solution_slot_id]).user_id == determine_no_solution_user.id
          # affecter no solution au slot overlappé
          a = SolutionSlot.find(overlap_info[:solution_slot_overlapped_id])
          a.user_id = determine_no_solution_user.id
          a.save!
        end
      end
    end
  end

  def get_overlaps_information(solution, slotgroups_array)
    # maps out all the overlaps
    # => [ {:solution_slot_id, :solution_slot_overlapped_id}, {...} ]
    overlaps_information = [] # init
    # réeordonner slotgroups_array du + prioritaire au - prioritaire
    temp_sg_array_sorted = slotgroups_array.sort_by{ |x| x.priority }
    # pour chaque slotgroup
    temp_sg_array_sorted.each do |slotgroup|
      # skip si pas d'overlap
      next if slotgroup.overlaps.empty?
      # get solution_slots related to the initial sg (=> Array)
      solution_slots_initial_sg = get_solution_slots_related_to_a_slotgroup(slotgroup.id, solution)
      # vérifier si overlap véritable
      slotgroup.overlaps.each do |overlap_array|
        # overlap_array = [ {:sg_id, :users}, {} ]
        next if slotgroup.overlaps.empty?
        # get solution_slots related to overlapped sg
        solution_slots_overlapped_sg = get_solution_slots_related_to_a_slotgroup(overlap_array[:slotgroup_id], solution)
        # sur chaque solution_slot initial
        solution_slots_initial_sg.each do |sol_slot_initial|
          solution_slots_overlapped_sg.each do |sol_slot_overlapped|
            if sol_slot_initial.user_id == sol_slot_overlapped.user_id && sol_slot_initial.user_id != determine_no_solution_user.id
              overlaps_information << {  solution_slot_id: sol_slot_initial.id, solution_slot_overlapped_id: sol_slot_overlapped.id }
            end
          end
        end
      end
    end
    return overlaps_information
  end

  def get_sg_hash_in_sg_array_according_to_sg_id(slotgroups_array, sg_id)
    slotgroups_array.select{ |sg_hash| sg_hash.id == sg_id }.first
  end

  def get_solution_slots_related_to_a_slotgroup(sg_id, solution)
    # return Array containing SolutionSlots
    sg_hash = get_sg_hash_in_sg_array_according_to_sg_id(@slotgroups_array, sg_id)
    # get list of ids of slots related to a slotgroup
    slots_to_simulate = [] #init
    sg_hash.slots_to_simulate.each do |slot_to_simulate|
      slots_to_simulate << slot_to_simulate[:slot_instance].id
    end
    # get solution_slots related to those slots
    return solution.solution_slots.select{ |sol_slot| slots_to_simulate.include?(sol_slot.slot_id) }
  end

  def determine_no_solution_user
    User.find_by(first_name: 'no solution')
  end
end
