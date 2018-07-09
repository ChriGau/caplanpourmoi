class AddColumnsForRankingToSolution < ActiveRecord::Migration[5.0]
  def change
    add_column :solutions, :conficts_percentage, :decimal
    add_column :solutions, :planning_fitness, :decimal
  end
end
