# frozen_string_literal: true

class AddColumnToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :slug, :string, null: false
    add_column :events, :is_local, :boolean, default: false
    remove_column :events, :membership_category, :string
    remove_column :events, :is_all_user, default: false
    remove_column :event_registrations, :membership_category
  end
end
