CREATE OR REPLACE FUNCTION get_objects_with_string(search_string TEXT)
RETURNS TABLE (object_name NAME)
AS $$
BEGIN
    RETURN QUERY
    SELECT proname::NAME AS object_name
    FROM pg_proc
    WHERE proname NOT IN (
        SELECT proname
        FROM pg_proc
        WHERE prosrc ILIKE '%OR REPLACE%'
    )
    AND prosrc ILIKE '%' || search_string || '%';
END;
$$ LANGUAGE plpgsql;

-- Проверить работоспособность: SELECT * FROM get_objects_with_string('UPDATE');