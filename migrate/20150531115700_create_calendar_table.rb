Sequel.migration do
  up do
    create_table(:calendar) do
      Date :xtn_date
      Date :xtn_week
      Date :xtn_month
      Date :xtn_year
      Integer :dow
      Integer :wom
      Integer :woy
    end
  end

  down do
    drop_table(:calendar)
  end
end
