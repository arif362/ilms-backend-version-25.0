class AddTrackNoToPublisher < ActiveRecord::Migration[7.0]
  def change
    add_column :publishers, :track_no, :string
  end
end
