class CreateSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :schedules do |t|
      t.string :title
      t.integer :talk_room_type_id
      t.string :talk_room_id
      t.string :schedule_type
      t.date :post_date
      t.string :post_day
      t.time :post_time
      t.string :create_user_id

      t.timestamps
    end
  end
end