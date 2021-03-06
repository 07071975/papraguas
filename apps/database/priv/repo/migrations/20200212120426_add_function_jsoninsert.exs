defmodule Database.Repo.Migrations.AddFunctionJsoninsert do
  use Ecto.Migration

  def change do
    execute """
      CREATE OR REPLACE FUNCTION jsoninsert(relname text, reljson text)
        RETURNS record AS
      $BODY$DECLARE
      ret RECORD;
      inputstring text;
      BEGIN
        SELECT string_agg(quote_ident(key),',') INTO inputstring
          FROM json_object_keys(reljson::json) AS X (key);
        EXECUTE 'INSERT INTO '|| quote_ident(relname)
          || '(' || inputstring || ') SELECT ' ||  inputstring
          || ' FROM json_populate_record( NULL::' || quote_ident(relname) || ' , json_in($1)) RETURNING *'
          INTO ret USING reljson::cstring;
        RETURN ret;
      END;
      $BODY$
      LANGUAGE plpgsql VOLATILE;
    """
  end
end
