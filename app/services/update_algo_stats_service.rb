# calculates AlgoStats caracteristics when clicking on 'reload' in /algo_statistics

class UpdateAlgoStatsService

  def initialize(algo_stat)
    @algo_stat = algo_stat
  end

  def perform
    # nb_compute_solutions (let's only count the ones on which we have measures)
    nb_compute_solutions = ComputeSolution.select{|c| !c.timestamps_algo.empty?}.count
    nb_fail = nb_compute_solutions - ComputeSolution.select{|c| c.timestamps_algo.length == 7}.count
    nb_solutions = 0
    go_through_total = 0
    solutions_storing_total = 0
    tree_covered_mean_total = 0
    total_mean_time = 0
    ComputeSolution.select{|c| !c.timestamps_algo.empty?}.each do |compute_solution|
      nb_solutions += compute_solution.solutions.count
      go_through_total += compute_solution.go_through_solutions_mean_time_per_slot
      solutions_storing_total += compute_solution.solution_storing_mean_time_per_slot
      tree_covered_mean_total += compute_solution.percent_tree_covered
      total_mean_time += compute_solution.calculation_length
    end
    @algo_stat.update(nb_compute_solutions: nb_compute_solutions,
      nb_solutions: nb_solutions,
      nb_fail: nb_fail,
      go_through_solutions_mean_time_per_slot: go_through_total / nb_compute_solutions,
      solutions_storing_mean_time: solutions_storing_total / nb_compute_solutions,
      tree_covered_mean: tree_covered_mean_total / nb_compute_solutions,
      total_mean_time: total_mean_time / nb_compute_solutions)
  end

end
