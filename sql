--Usuwanie wszystkich widoków
BEGIN
  FOR i IN
  (SELECT view_name FROM user_views
  )
  LOOP
    EXECUTE immediate 'drop view ' || i.view_name;
  END LOOP;
END;
/
SET SERVEROUTPUT ON;
DECLARE
  col_num  NUMBER NOT NULL :=0;
  counting NUMBER NOT NULL :=0;
  ncolumn  VARCHAR2(20);
  row_num  NUMBER NOT NULL :=0;
  rowcount NUMBER NOT NULL :=0;
BEGIN
  SELECT COUNT(column_name) AS numbers
  INTO col_num
  FROM cols
  WHERE table_name LIKE 'DAN%';
  UPDATE pom SET counter = 0;
  UPDATE pom SET OBJECT_COUNT=0;
  SELECT MAX(ROWNUM) INTO row_num FROM dane;
  DBMS_OUTPUT.PUT_LINE('Bla ' || rowcount || row_num);
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
    --Druga pętla tworząca widoki z danymi
    LOOP
      UPDATE pom SET OBJECT_COUNT=OBJECT_COUNT+1;
      EXECUTE immediate 'CREATE OR REPLACE VIEW v_data'||rowcount||''||counting||' 
AS  
SELECT * from dane where '||ncolumn||'=(select '||ncolumn||' from dane where id='||rowcount||')';
      rowcount:=rowcount+1;
      EXIT
    WHEN rowcount=row_num+1;
    END LOOP;
    EXIT
  WHEN counting=col_num-2;
  END LOOP;
  UPDATE pom set OBJECT_COUNT=OBJECT_COUNT/COUNTER;
EXCEPTION
WHEN no_data_found THEN
  dbms_output.put_line('Table NOT found');
END;
/
