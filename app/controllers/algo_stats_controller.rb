
class AlgoStatsController < ApplicationController

def show_statistics_algo
  @algo_stat = AlgoStat.last
end

def reload_statistics
  algo_stat = AlgoStat.create!
  UpdateAlgoStatsService.new(algo_stat).perform
  redirect_to statistics_algo_path
end

end
