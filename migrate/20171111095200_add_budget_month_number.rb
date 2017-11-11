Sequel.migration do
  change do
    alter_table :budget_periods do
      add_column :month, Integer
    end
  end
end
