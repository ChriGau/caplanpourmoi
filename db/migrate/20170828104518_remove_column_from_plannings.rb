class RemoveColumnFromPlannings < ActiveRecord::Migration[5.0]
  def change
    remove_column :plannings, :team_id, :integer
  end
end
