class AddCreatedByIdAndTypeToMultipleModel < ActiveRecord::Migration[7.0]
  def change

        add_column :users, :created_by_type, :string
        add_column :users, :updated_by_type, :string

        add_column :membership_requests, :created_by_type, :string
        add_column :membership_requests, :updated_by_type, :string

        add_column :request_details, :created_by_type, :string
        add_column :request_details, :updated_by_type, :string

        add_column :security_moneys, :created_by_id, :integer
        add_column :security_moneys, :updated_by_id, :integer
        add_column :security_moneys, :created_by_type, :string
        add_column :security_moneys, :updated_by_type, :string

        add_column :library_cards, :created_by_id, :integer
        add_column :library_cards, :updated_by_id, :integer
        add_column :library_cards, :created_by_type, :string
        add_column :library_cards, :updated_by_type, :string

        add_column :lost_damaged_biblios, :created_by_id, :integer
        add_column :lost_damaged_biblios, :updated_by_id, :integer
        add_column :lost_damaged_biblios, :created_by_type, :string
        add_column :lost_damaged_biblios, :updated_by_type, :string

  end
end
