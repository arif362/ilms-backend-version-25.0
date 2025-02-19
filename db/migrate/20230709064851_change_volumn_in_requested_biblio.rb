class ChangeVolumnInRequestedBiblio < ActiveRecord::Migration[7.0]
  def change
    reversible do |rb|
      rb.up do
        rename_column :requested_biblios, :number_of_pages, :volume
        change_column :requested_biblios, :volume, :string
      end
      rb.down do
        change_column :requested_biblios, :volume, :integer
        rename_column :requested_biblios, :volume, :number_of_pages
      end
    end
  end
end

