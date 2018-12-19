
class AlgoStatsController < ApplicationController

def show_statistics_algo
  unless AlgoStat.count.zero?
    @algo_stat = AlgoStat.last
    @compute_solutions = ComputeSolution.last(50).select{|c| c.status != "pending"}.last(15)
    @table_rows = []
    @compute_solutions.each do |compute_solution|
      @table_rows << compute_solution.build_row_for_statistics_display
    end
    @bar_chart_rows = @algo_stat.calculations_per_week(@compute_solutions, "01/06/2018".to_date)
    @curve_chart_rows = curve_chart_rows
  end
end

def reload_statistics
  algo_stat = AlgoStat.create!
  UpdateAlgoStatsService.new().perform
  redirect_to statistics_algo_path
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
