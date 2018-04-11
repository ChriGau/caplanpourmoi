class CreateColors < ActiveRecord::Migration[5.0]
  def change
    create_table :colors do |t|
      t.text :name_fr
      t.text :name_eng
      t.text :hexadecimal_code

      t.timestamps
    end
  end
end
