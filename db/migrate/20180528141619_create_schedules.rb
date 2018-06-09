class CreateSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :schedules do |t|
      t.string :title
      t.integer :talk_room_type_id
      t.string :talk_room_id
      t.string :schedule_type
      t.integer :post_year
      t.integer :post_month
      t.integer :post_day
      t.integer :post_wday
      t.integer :post_hour
      t.integer :post_minute
      t.string :create_user_id

      t.timestamps
    end
  end
end
