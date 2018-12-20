
class AlgoStatsController < ApplicationController

def show_statistics_algo
  @success = true # init
  unless AlgoStat.count.zero?
    @algo_stat = AlgoStat.last
    authorize @algo_stat
    @compute_solutions = ComputeSolution.last(50).select{|c| c.status != "pending"}.last(15)
    @table_rows = []
    @compute_solutions.each do |compute_solution|
      @table_rows << compute_solution.build_row_for_statistics_display
    end
    @bar_chart_rows = @algo_stat.calculations_per_week(@compute_solutions, "01/06/2018".to_date)
    @curve_chart_rows = curve_chart_rows
  else
    # pas d'algostat présent => mettre à jour les statistiques
    @success = reload_statistics
  end
end

def reload_statistics
  # => create AlgoStat + calculate its attributes
  # => true if AlgoStat contains solutions. If false, no stats can be displayed
  algo_stat = AlgoStat.create!
  authorize algo_stat
  redirect_to statistics_algo_path
  return UpdateAlgoStatsService.new(algostat: algo_stat).perform
end

private

def curve_chart_rows
  # [[AlgoStat ID, tps moyen]]
  result = []
  AlgoStat.select{ |a| a.nb_fail != nil }.last(100).each do |a|
    result << [a.id, a.go_through_solutions_mean_time_per_slot]
  end
  result
end

end
