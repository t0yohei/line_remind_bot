class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.string :roomId
      t.string :fanctionId
      t.string :userId

      t.timestamps
    end
  end
end
