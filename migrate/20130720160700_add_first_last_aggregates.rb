Sequel.migration do
  up do
    run """
      -- Create a function that always returns the first non-NULL item
      CREATE OR REPLACE FUNCTION public.first_agg ( anyelement, anyelement )
      RETURNS anyelement LANGUAGE sql IMMUTABLE STRICT AS $$
              SELECT $1;
      $$;
       
      -- And then wrap an aggregate around it
      CREATE AGGREGATE public.first (
              sfunc    = public.first_agg,
              basetype = anyelement,
              stype    = anyelement
      );
       
      -- Create a function that always returns the last non-NULL item
      CREATE OR REPLACE FUNCTION public.last_agg ( anyelement, anyelement )
      RETURNS anyelement LANGUAGE sql IMMUTABLE STRICT AS $$
              SELECT $2;
      $$;
       
      -- And then wrap an aggregate around it
      CREATE AGGREGATE public.last (
              sfunc    = public.last_agg,
              basetype = anyelement,
              stype    = anyelement
      );
    """
  end
  down do
    run """
      drop aggregate first(anyelement);
      drop function first_agg(anyelement, anyelement);
      drop aggregate last(anyelement);
      drop function last_agg(anyelement, anyelement);
    """
  end
end
