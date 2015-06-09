Sequel.migration do
  change do
    add_column :asset_allocation, :er, :numeric
  end
end
