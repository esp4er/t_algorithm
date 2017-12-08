create or replace PROCEDURE             BLAD 
IS
  v_kolumna         VARCHAR2(2000);
  v_ile_obiektow    NUMBER;
  v_decyzja         VARCHAR2(2000);
  v_wartosc         VARCHAR2(2000);
  v_licznik         NUMBER;
  v_obiekt_licznik  NUMBER;
  v_obiekt_id       NUMBER;
  v_dlugosc_decyzji NUMBER;
  queries           VARCHAR2(2000);
  queries2           VARCHAR2(2000);
BEGIN
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
  v_licznik:=1;
  SELECT MAX(OBIEKT) INTO v_ile_obiektow FROM wynik;
  SELECT MAX(wynik_id) INTO v_obiekt_id FROM wynik;
  dbms_output.put_line(v_obiekt_id||'ile razy');
  FOR i IN 1..v_obiekt_id
  LOOP
    SELECT dlugosc_decyzji
    INTO v_dlugosc_decyzji
    FROM wynik
    WHERE wynik_id=v_licznik;
    dbms_output.put_line(v_licznik||'V_LICZNIK_POCZATEK');
    SELECT wartosc INTO v_wartosc FROM wynik WHERE wynik_id=v_licznik;
    SELECT decyzja INTO v_decyzja FROM wynik WHERE wynik_id=v_licznik;
    SELECT kolumna INTO v_kolumna FROM wynik WHERE wynik_id=v_licznik;
    dbms_output.put_line(v_decyzja||'nazwa kolumny');    
    SELECT obiekt INTO v_obiekt_id FROM wynik WHERE wynik_id=v_licznik;
    EXECUTE IMMEDIATE 'CREATE table v_TEMP as select * from dane';
    LOOP
      SELECT wartosc INTO v_wartosc FROM wynik WHERE wynik_id=v_licznik;
      SELECT decyzja INTO v_decyzja FROM wynik WHERE wynik_id=v_licznik;
      SELECT kolumna INTO v_kolumna FROM wynik WHERE wynik_id=v_licznik;
      IF v_dlugosc_decyzji = 1 THEN
        queries:= 'create table v_blad'||v_obiekt_id||' as select * from v_temp where '||v_kolumna||'='''||v_wartosc||''' and decyzja<>'''||v_decyzja||'''';       
        EXECUTE IMMEDIATE queries;
        dbms_output.put_line('POWINIENEM BYC TUTAJ');
        dbms_output.put_line('Dlugosc decyzji, początek pętli bez v_tym: '||v_dlugosc_decyzji);
        v_dlugosc_decyzji:=v_dlugosc_decyzji-1;
        v_licznik        :=v_licznik        +1;
      ELSE
        LOOP
          SELECT wartosc INTO v_wartosc FROM wynik WHERE wynik_id=v_licznik;
          SELECT decyzja INTO v_decyzja FROM wynik WHERE wynik_id=v_licznik;
          SELECT kolumna INTO v_kolumna FROM wynik WHERE wynik_id=v_licznik;
          queries2:='CREATE table V_TYM as select * FROM V_TEMP where '||v_kolumna||'='''||v_wartosc||''' and DECYZJA<>'''||v_decyzja||''' and id='''||v_obiekt_id||'''';
          EXECUTE IMMEDIATE queries2;
          dbms_output.put_line('JESTEM TUTAJ');
          EXECUTE IMMEDIATE 'drop table V_TEMP';
          EXECUTE IMMEDIATE 'alter table V_TYM rename to V_TEMP';
          v_dlugosc_decyzji:=v_dlugosc_decyzji-1;
          dbms_output.put_line('Dlugosc decyzji'||v_dlugosc_decyzji);
          v_licznik:=v_licznik+1;
          EXIT
        WHEN v_dlugosc_decyzji=1;
        END LOOP;
      END IF;
      EXIT
    WHEN v_dlugosc_decyzji=0;
    END LOOP;
    EXECUTE IMMEDIATE 'DROP TABLE V_TEMP';
    dbms_output.put_line(v_licznik||' Licznik');
    --v_licznik:=v_licznik+1;
    EXIT
  WHEN v_obiekt_id=v_licznik;
  END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  dbms_output.put_line('Koniec');
WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
END IF;
END;