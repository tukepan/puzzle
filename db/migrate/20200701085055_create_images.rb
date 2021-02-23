class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.string :img
      t.integer :puzzle_id
      t.integer :answer_id
      t.timestamps null: false
    end
  end
end
