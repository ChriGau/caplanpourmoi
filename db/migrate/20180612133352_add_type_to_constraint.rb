class AddTypeToConstraint < ActiveRecord::Migration[5.0]
  def change
    add_column :constraints, :category, :integer
    add_column :constraints, :status, :integer
  end
end
