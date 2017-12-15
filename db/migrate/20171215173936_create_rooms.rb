class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.string :room_id
      t.string :fanction
      t.string :userID

      t.timestamps
    end
  end
end
