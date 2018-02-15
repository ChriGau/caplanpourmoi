class AddTimestampsToSolution < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :solutions, null: true
    Solution.update_all(created_at: DateTime.now, updated_at: DateTime.now)
    change_column_null :solutions, :created_at, false
    change_column_null :solutions, :updated_at, false
  end
end
