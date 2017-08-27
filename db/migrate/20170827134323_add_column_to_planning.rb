class AddColumnToPlanning < ActiveRecord::Migration[5.0]
  def change
    add_reference :plannings, :team, foreign_key: true
  end
end
