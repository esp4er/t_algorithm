create or replace PROCEDURE UAKT_WYNIK
IS
  v_id            NUMBER;
  v_obiekt_id     NUMBER;
  v_nazwa_kolumny VARCHAR2(2000);
BEGIN
  SELECT COUNT(*) INTO v_id FROM wynik;
  FOR j IN 1..v_id
  LOOP
    SELECT obiekt INTO v_obiekt_id FROM wynik WHERE wynik_id=j;
    SELECT kolumna INTO v_nazwa_kolumny FROM wynik where WYNIK_ID=j;
    dbms_output.put_line( 'Nazwa kolumny aktualna'||v_nazwa_kolumny);
    dbms_output.put_line(v_obiekt_id);
    EXECUTE IMMEDIATE 'UPDATE wynik set WARTOSC=(select '||v_nazwa_kolumny||' from dane where id='||v_obiekt_id||') where wynik_id=:j'using j;
    EXECUTE IMMEDIATE 'UPDATE wynik set decyzja=(select decyzja from pom where obiekt_id='||v_obiekt_id||')where wynik_id=:j'using j;
    EXECUTE IMMEDIATE 'UPDATE wynik set dlugosc_decyzji=(select dlugosc from v_wynik where obiekt_id='||v_obiekt_id||')where wynik_id=:j'using j;
  END LOOP;
END;