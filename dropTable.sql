create or replace PROCEDURE DROP_TABLE
IS
BEGIN
  FOR rec IN
  (SELECT table_name
  FROM all_tables
  WHERE table_name LIKE '%V_POKRYCIE%'
  OR table_name LIKE '%V_BLAD%'
  )
  LOOP
    EXECUTE immediate 'drop table '||rec.table_name;
  END LOOP;
  EXECUTE immediate 'drop table v_temp';
EXCEPTION
WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;