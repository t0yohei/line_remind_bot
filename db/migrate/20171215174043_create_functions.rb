class CreateFunctions < ActiveRecord::Migration[5.1]
  def change
    create_table :functions do |t|
      t.string :fuction_id
      t.string :name

      t.timestamps
    end
  end
end
