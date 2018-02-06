class AddForeignKeyToSolution < ActiveRecord::Migration[5.0]
  def change
    add_reference :solutions, :compute_solution, foreign_key: true, index: true
  end
end
