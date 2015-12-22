SET SERVEROUTPUT ON;
DECLARE
  v_names VARCHAR2(10);
  counting NUMBER NOT NULL :=1;
  v_id NUMBER;
BEGIN
  LOOP
    SELECT view_name INTO v_names FROM v_name WHERE id=counting;
    SELECT max(id) into v_id from v_name; 
    EXECUTE immediate 'SELECT COUNT(WYNIK) AS freq, WYNIK FROM '|| v_names|| ' GROUP BY WYNIK ORDER BY WYNIK';
    counting:=counting+1;
    EXIT
  WHEN counting=v_id+1;
  END LOOP;
END;
/
CREATE OR REPLACE VIEW v_name
AS
  SELECT view_name, rownum AS id FROM user_views WHERE view_name LIKE '%DATA%';
