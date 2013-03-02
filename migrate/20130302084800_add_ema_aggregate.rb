Sequel.migration do
  up do
    run """
      create or replace function ema_func(state numeric, inval numeric, alpha numeric)
        returns numeric
        language sql as $$
      select case
             when $1 is null then $2
             else $3 * $2 + (1-$3) * $1
             end
      $$;
      
      create  aggregate ema(numeric, numeric) (sfunc = ema_func, stype = numeric);        
    """
  end
  down do
    run """
      drop aggregate ema(numeric, numeric);
      drop function ema_func(numeric, numeric, numeric);
    """
  end
end
        
