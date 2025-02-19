class CreateDistributions < ActiveRecord::Migration[7.0]
  def change
    create_table :distributions do |t|
      t.integer :status

      t.timestamps
    end
  end
end
