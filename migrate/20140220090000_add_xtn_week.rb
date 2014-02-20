Sequel.migration do
  change do
    alter_table :ledger do
      add_column :xtn_week, Date
      add_index :xtn_week
    end
  end
end
