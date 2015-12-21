SET SERVEROUTPUT ON;
DECLARE
  v_value  NUMBER NOT NULL :=0;
  counting NUMBER NOT NULL :=0;
  ncolumn  VARCHAR2(20);
BEGIN
  SELECT COUNT(column_name) AS numbers
  INTO v_value
  FROM cols
  WHERE table_name LIKE 'DAN%';
  UPDATE pom SET counter = 0;
  --  Select dane.*, c.column_id from user_tab_columns c inner JOIN dane on dane.ATR=c.column_name;
  LOOP
    UPDATE pom SET counter = counter+1;
    SELECT column_name
    INTO ncolumn
    FROM cols
    WHERE table_name LIKE 'DAN%'
    AND COLUMN_ID=
      (SELECT counter FROM pom
      );
    --SELECT * FROM dane WHERE :ncolumn=1;
    --select * from DANE where ROWNUM=1;
    counting:=counting+1;
    DBMS_OUTPUT.PUT_LINE('Hello ' || counting);
    DBMS_OUTPUT.PUT_LINE('Hello ' || ncolumn);
    EXECUTE immediate 'CREATE OR REPLACE VIEW v_data'||counting||'
AS  
SELECT * from dane where '||ncolumn||'='||counting||'';
    EXIT
  WHEN counting=v_value;
  END LOOP;
EXCEPTION
WHEN no_data_found THEN
  dbms_output.put_line('Table NOT found');
END;
/
--select * from dane where rownum=counter and 
