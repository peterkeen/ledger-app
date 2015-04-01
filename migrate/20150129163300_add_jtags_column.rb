Sequel.migration do
  change do
    add_column :ledger, :jtags, :json
  end
end
