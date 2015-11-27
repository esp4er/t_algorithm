set SERVEROUTPUT ON;
Declare 
v_value number (10,2);
BEGIN
select atr into v_value
from T_ALGORITHM.DATA
where ATR=0;
DBMS_OUTPUT.PUT_LINE('Hello ' || v_value);
END;
/
