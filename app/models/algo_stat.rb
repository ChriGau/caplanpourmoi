# == Schema Information
#
# Table name: algo_stats
#
#  id                                      :integer          not null, primary key
#  nb_compute_solutions                    :integer
#  nb_solutions                            :integer
#  nb_fail                                 :integer
#  go_through_solutions_mean_time_per_slot :float
#  solutions_storing_mean_time             :float
#  tree_covered_mean                       :float
#  total_mean_time                         :float
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#

class AlgoStat < ApplicationRecord

def calculations_per_week(compute_solutions, start_date)
  # => [[week_number, nb of calculations]]
  result = []
  [start_date.cweek .. Date.today.cweek].first.each do |week_number|
    result << [week_number, ComputeSolution.select{|c| c.created_at.to_date.cweek == week_number}.count]
  end
  return result
end

end
