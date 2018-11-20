class AddColumnsForRankingToSolution < ActiveRecord::Migration[5.0]
  def change
    add_column :solutions, :conflicts_percentage, :decimal
    add_column :solutions, :fitness, :decimal
    add_column :solutions, :grade, :decimal
  end
end
