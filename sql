SET SERVEROUTPUT ON;
DECLARE
  v_value NUMBER not null :=0;
  counting NUMBER not null :=0;
  ncolumn VARCHAR2(20);

BEGIN
  SELECT COUNT(column_name) AS numbers
  INTO v_value
  FROM cols
  WHERE table_name LIKE 'DAN%';
      UPDATE pom
      SET counter = 0;  
  --  Select dane.*, c.column_id from user_tab_columns c inner JOIN dane on dane.ATR=c.column_name;
  LOOP
    UPDATE pom
    SET counter = counter+1;
    SELECT column_name INTO ncolumn FROM cols WHERE table_name LIKE 'DAN%' and COLUMN_ID= :counting;--(select counter from pom);
  --SELECT * FROM dane WHERE :ncolumn=1; 
    --select * from DANE where ROWNUM=1;
    counting:=counting+1;
    DBMS_OUTPUT.PUT_LINE('Hello ' || counting);
    DBMS_OUTPUT.PUT_LINE('Hello ' || ncolumn);
    EXECUTE immediate 'CREATE OR REPLACE VIEW v_data
AS  
SELECT * from data where '||ncolumn||'=ATR';
    EXIT
  WHEN counting=v_value;
  END LOOP;
END;
/
--select * from dane where rownum=counter and 
