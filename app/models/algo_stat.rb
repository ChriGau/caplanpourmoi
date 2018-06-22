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
end
