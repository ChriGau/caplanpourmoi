class AddColumnsToSolution < ActiveRecord::Migration[5.0]
  def change
    add_column :solutions, :effectivity, :integer
    add_column :solutions, :relevance, :integer
    remove_column :solutions, :status, :string
    remove_column :solutions, :calculsolutionv1_id, :integer
  end
end
