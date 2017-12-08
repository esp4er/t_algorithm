create or replace PROCEDURE DEL_VIEW AS 
BEGIN
  FOR i IN
  (SELECT view_name FROM user_views
  )
  LOOP
    EXECUTE immediate 'drop view ' || i.view_name;
  END LOOP;
  NULL;
END DEL_VIEW;