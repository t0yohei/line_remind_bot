class CreateTalkRoomTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :talk_room_types do |t|
      t.string :type_name

      t.timestamps
    end
  end
end
