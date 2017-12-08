create or replace PROCEDURE "RUN"(
    p_par_uzytk VARCHAR2 )
IS
  P_PAR_UZYT      VARCHAR2(200);
  P_TABELA        VARCHAR2(200);
  P_NAZWA_KOLUMNY VARCHAR2(200);
  P_ID_KOLUMNY    VARCHAR2(200);
  P_ID_WIERSZA    VARCHAR2(200);
  P_KONIEC        VARCHAR2(200);
  P_LISTA_KOL     VARCHAR2(200);
  zstart          NUMBER;
  zkoniec         NUMBER;
BEGIN
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
  zstart := dbms_utility.get_time();
  FOR I IN
  (SELECT * FROM DANE
  )
  LOOP
    P_PAR_UZYT      := p_par_uzytk;
    P_TABELA        := 'DANE';
    P_NAZWA_KOLUMNY := NULL;
    P_ID_KOLUMNY    := NULL;
    P_ID_WIERSZA    := I.ID;
    P_KONIEC        := NULL;
    P_LISTA_KOL     := NULL;
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE DANE1';
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE DANE2';
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    EXECUTE IMMEDIATE 'CREATE TABLE DANE1 AS SELECT * FROM DANE where 1<>1';
    EXECUTE IMMEDIATE 'CREATE TABLE DANE2 AS SELECT * FROM DANE where 1<>1';
    DELETE wyniki;
    ALGORYTM( P_PAR_UZYT => P_PAR_UZYT, P_TABELA => P_TABELA, P_NAZWA_KOLUMNY => P_NAZWA_KOLUMNY, P_ID_KOLUMNY => P_ID_KOLUMNY, P_ID_WIERSZA => P_ID_WIERSZA, P_KONIEC => P_KONIEC, P_LISTA_KOL => P_LISTA_KOL );
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('P_LISTA_KOL = ' || P_LISTA_KOL);
  zkoniec:=(dbms_utility.get_time()-zstart)/100;
  delete czas;
  EXECUTE IMMEDIATE 'INSERT INTO CZAS (CZAS, PARAMETR_UZYTKOWNIKA) values (:zkoniec, :P_PAR_UZYT)'using zkoniec, p_par_uzyt;
END;