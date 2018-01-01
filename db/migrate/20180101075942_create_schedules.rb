class CreateSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :schedules do |t|
      t.date :date
      t.string :roomId
      t.string :contents
      t.string :functionId

      t.timestamps
    end
  end
end
