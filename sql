SET SERVEROUTPUT ON;
DECLARE
  v_value  NUMBER NOT NULL :=0;
  counting NUMBER NOT NULL :=0;
  ncolumn  VARCHAR2(20);
  rowno    NUMBER NOT NULL :=0;
  rowcount NUMBER NOT NULL :=0;
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
    counting:=counting+1;
    rowcount:=1;
    --DBMS_OUTPUT.PUT_LINE('Hello ' || counting);
    --DBMS_OUTPUT.PUT_LINE('Hello ' || ncolumn);
    LOOP
      SELECT MAX(ROWNUM) INTO rowno FROM dane;
      DBMS_OUTPUT.PUT_LINE('Bla ' || rowcount || rowno);
      EXECUTE immediate 'CREATE OR REPLACE VIEW v_data'||counting||''||rowcount||' 
AS  
SELECT * from dane where '||ncolumn||'=(select'||ncolumn||'from dane where rownum='||rowcount||'and'||ncolumn||'='||counting||')';
      rowcount:=rowcount+1;
      EXIT
    WHEN rowcount=rowno+1;
    END LOOP;
    EXIT
  WHEN counting=v_value-1;
  END LOOP;
EXCEPTION
WHEN no_data_found THEN
  dbms_output.put_line('Table NOT found');
END;
       /
--SELECT *
--FROM dane
--WHERE atr=
--  (SELECT atr FROM dane WHERE rownum=1 AND atr=1
--  )
--  begin
--        for i in (select view_name from user_views) loop
--          execute immediate 'drop view ' || i.view_name;
--        end loop;
--      end;
