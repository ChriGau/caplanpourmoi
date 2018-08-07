class AddRankingColumnsToSolution < ActiveRecord::Migration[5.0]
  def change
    add_column :solutions, :nb_users_six_consec_days_fail, :integer
    add_column :solutions, :nb_users_daily_hours_fail, :integer
    add_column :solutions, :compactness, :integer
    add_column :solutions, :nb_users_in_overtime, :integer
  end
end
