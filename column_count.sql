--Tworzenie widoku z nazwami pozostaych widoków
CREATE OR REPLACE VIEW v_name
AS
SELECT view_name, rownum AS id FROM user_views WHERE view_name LIKE '%DATA%';
  DROP TABLE temp;
  DROP TRIGGER TEMP_ID;
  DROP SEQUENCE temp_seq;
  CREATE TABLE temp
    (
      ID        NUMBER DEFAULT 0 NOT NULL ENABLE,
      CZEST     NUMBER,
      MAXIMUM   NUMBER,
      VIEW_NAME VARCHAR2(50),
      CONSTRAINT "TEMP_ID_PK" PRIMARY KEY ("ID")
    );
CREATE SEQUENCE "T_ALGORITHM"."TEMP_SEQ" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE ;    
CREATE OR REPLACE TRIGGER "T_ALGORITHM"."TEMP_ID" BEFORE
  INSERT ON temp FOR EACH ROW BEGIN :new.id := temp_seq.nextval;
END;
/
ALTER TRIGGER "T_ALGORITHM"."TEMP_ID" ENABLE;
  SET SERVEROUTPUT ON;
  DECLARE
    v_names  VARCHAR2(10);
    counting NUMBER NOT NULL :=1;
    v_id     NUMBER;
    row_num number;
    row_count number:=1;
  BEGIN
    LOOP
      SELECT view_name INTO v_names FROM v_name WHERE id=counting;
      SELECT MAX(id) INTO v_id FROM v_name;
      Select a.OBJECT_COUNT into row_num from pom a;
      EXECUTE IMMEDIATE 'INSERT INTO temp (czest, maximum)    
SELECT MAX(      
(SELECT MAX(COUNT(WYNIK)) AS freq FROM ' ||v_names|| ' GROUP BY WYNIK      
)) AS czest,      
COUNT((SELECT COUNT(wynik) FROM '||v_names|| '      
)) AS maximum      
FROM '||v_names||'';
      EXECUTE IMMEDIATE 'update temp set VIEW_NAME = (SELECT VIEW_NAME FROM v_name where id='||counting||')where id='||counting||'';
      counting:=counting+1;
      EXIT
    WHEN counting=v_id+1;
    END LOOP;
          loop
execute immediate 'create or replace view v_wynik'||row_count||' as
select a.view_name, (a.MAXIMUM-a.CZEST) as wynik from temp a where view_name like ''V_DATA'||row_count||'%'' order by a.VIEW_NAME ';
row_count:=row_count+1;
exit when row_count=row_num+1;
end loop;
  END;
  /
