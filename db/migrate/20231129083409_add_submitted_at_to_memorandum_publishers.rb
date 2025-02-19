class AddSubmittedAtToMemorandumPublishers < ActiveRecord::Migration[7.0]
  def change
    add_column :memorandum_publishers, :submitted_at, :datetime
  end
end
