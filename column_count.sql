DROP TABLE temp;
DROP TRIGGER TEMP_ID;
DROP SEQUENCE temp_seq;
CREATE TABLE temp
  (
    ID      NUMBER DEFAULT 0 NOT NULL ENABLE,
    CZEST   NUMBER,
    MAXIMUM NUMBER,
    CONSTRAINT "TEMP_ID_PK" PRIMARY KEY ("ID")
  );
CREATE OR REPLACE TRIGGER "T_ALGORITHM"."TEMP_ID" BEFORE
  INSERT ON temp FOR EACH ROW BEGIN :new.id := temp_seq.nextval;
END;
/
ALTER TRIGGER "T_ALGORITHM"."TEMP_ID" ENABLE;
CREATE SEQUENCE  "T_ALGORITHM"."TEMP_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE ;
SET SERVEROUTPUT ON;
DECLARE
  v_names  VARCHAR2(10);
  counting NUMBER NOT NULL :=1;
  v_id     NUMBER;
BEGIN
  LOOP
    SELECT view_name INTO v_names FROM v_name WHERE id=counting;
    SELECT MAX(id) INTO v_id FROM v_name;
    EXECUTE IMMEDIATE 'INSERT INTO temp (czest, maximum)    
SELECT MAX(      
(SELECT MAX(COUNT(WYNIK)) AS freq FROM ' ||v_names|| ' GROUP BY WYNIK      
)) AS czest,      
COUNT((SELECT COUNT(wynik) FROM '||v_names|| '      
)) AS maximum      
FROM '||v_names||'';
    counting:=counting+1;
    EXIT
  WHEN counting=v_id+1;
  END LOOP;
END;
/
CREATE OR REPLACE VIEW v_temp as SELECT a.*, d.VIEW_NAME FROM temp a, v_name d where a.id=d.id;
CREATE OR REPLACE VIEW v_name
AS
  SELECT view_name, rownum AS id FROM user_views WHERE view_name LIKE '%DATA%'; 
