set SERVEROUTPUT ON;
Declare 
v_value number (10,2);
BEGIN
SELECT count(column_name) as numbers into v_value
FROM cols
WHERE table_name LIKE 'DAT%';
DBMS_OUTPUT.PUT_LINE('Hello ' || v_value);
END;
/
