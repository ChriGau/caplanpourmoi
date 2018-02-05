class Addforeignkeytocalculsolutionv1 < ActiveRecord::Migration[5.0]
  def change
    add_reference :calcul_solution_v1s, :compute_solution, foreign_key: true, index: true
  end
end
