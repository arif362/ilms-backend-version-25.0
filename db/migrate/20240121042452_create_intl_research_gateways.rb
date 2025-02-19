class CreateIntlResearchGateways < ActiveRecord::Migration[7.0]
  def change
    create_table :intl_research_gateways do |t|
      t.string :name
      t.string :url
      t.boolean :is_deleted
      t.boolean :is_published
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
