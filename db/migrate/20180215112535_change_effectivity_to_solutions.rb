class ChangeEffectivityToSolutions < ActiveRecord::Migration[5.0]
  def up
    change_column_default(:solutions, :effectivity, 0)
  end

  def down
    change_column_default(:solutions, :effectivity, nil)
  end
end
