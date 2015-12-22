drop table temp;
SET SERVEROUTPUT ON;
DECLARE
  v_names  VARCHAR2(10);
  counting NUMBER NOT NULL :=1;
  v_id     NUMBER;
BEGIN
  EXECUTE IMMEDIATE 'create table temp (        
CZEST NUMBER,        
MAXIMUM NUMBER      
)';
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
CREATE OR REPLACE VIEW v_name
AS
  SELECT view_name, rownum AS id FROM user_views WHERE view_name LIKE '%DATA%'; 
