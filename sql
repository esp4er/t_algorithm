SET SERVEROUTPUT ON;
DECLARE
  v_value NUMBER:=0;
  counter NUMBER:=0;
BEGIN
  SELECT COUNT(column_name) AS numbers
  INTO v_value
  FROM cols
  WHERE table_name LIKE 'DAN%';
  DBMS_OUTPUT.PUT_LINE('Hello ' || v_value);
  Select * from dane;
--  Select dane.*, c.column_id from user_tab_columns c inner JOIN dane on dane.ATR=c.column_name;
  LOOP
    counter:=counter+1;
    DBMS_OUTPUT.PUT_LINE('Hello ' || counter);
    EXECUTE immediate 'CREATE OR REPLACE VIEW v_data
AS  
SELECT * from data where column_id=1';
    EXIT
  WHEN counter=v_value;
  END LOOP;
END;
/
