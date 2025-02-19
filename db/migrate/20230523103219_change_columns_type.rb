class ChangeColumnsType < ActiveRecord::Migration[7.0]
  def change
    change_column(:notices, :title, :text)
    change_column(:notices, :bn_title, :text)
  end
end
