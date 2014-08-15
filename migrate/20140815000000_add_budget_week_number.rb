Sequel.migration do
  change do
    alter_table :budget_periods do
      add_column :week, Integer
    end
  end
end
