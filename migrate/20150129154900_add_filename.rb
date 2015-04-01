Sequel.migration do
  up do
    add_column :ledger, :filename, String
  end

  down do
    drop_column :ledger, :filename
  end
end
