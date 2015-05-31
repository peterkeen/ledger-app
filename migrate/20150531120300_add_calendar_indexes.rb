Sequel.migration do
  change do
    alter_table :calendar do
      add_index :xtn_date
      add_index :xtn_week
      add_index :xtn_month
      add_index :xtn_year
      add_index :dow
      add_index :wom
      add_index :woy
    end
  end
end
