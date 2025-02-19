class CreateMemorandumPublishers < ActiveRecord::Migration[7.0]
  def change
    create_table :memorandum_publishers do |t|
      t.bigint :publisher_id
      t.bigint :memorandum_id
      t.string :track_no
      t.boolean :is_shortlisted, default: false
      t.boolean :is_final_submitted, default: false
      t.timestamps
    end
  end
end
