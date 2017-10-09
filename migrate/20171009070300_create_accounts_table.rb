Sequel.migration do
  change do
    create_table(:accounts) do
      Text :account
      Text :tag
      index [:account, :tag]
    end
  end
end
