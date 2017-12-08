create or replace PROCEDURE V_WYNIKI
IS
  v_pom           NUMBER;
  v_licznik       NUMBER;
  v_obiekty       NUMBER;
  v_iteracje      NUMBER;
  v_kolumny       NUMBER;
  v_nazwa_kolumny VARCHAR2(2000);
  v_tabela        VARCHAR2(2000);
  v_id            NUMBER;
  v_obiekt_id     NUMBER;
  v_select        VARCHAR2(2000);
  v_kolumna       VARCHAR2(2000);
  v_licz_kol      NUMBER;
BEGIN
  v_select:='SELECT regexp_count(dlugosc_decyzji, '','') AS "DLUGOSC", OBIEKT_ID FROM pom';
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW v_wynik AS '||v_select||'';
  EXECUTE IMMEDIATE 'drop TRIGGER wynik_id';
  EXECUTE IMMEDIATE 'drop SEQUENCE wynik_seq';
  EXECUTE IMMEDIATE 'drop table wynik';
  EXECUTE IMMEDIATE 'CREATE TABLE "T_ALGORITHM"."WYNIK"    
( "KOLUMNA" NVARCHAR2(2000),  
"WARTOSC" VARCHAR2(2000 BYTE),  
"DLUGOSC_DECYZJI" VARCHAR2(2000 BYTE),  
"DECYZJA" VARCHAR2(2000 BYTE),  
"OBIEKT" NUMBER,  
"WYNIK_ID" NUMBER NOT NULL ENABLE,   
CONSTRAINT "WYNIK_PK" PRIMARY KEY ("WYNIK_ID")  
USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS   
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  
TABLESPACE "SYSTEM"  ENABLE   
) SEGMENT CREATION IMMEDIATE   
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING  
STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645  
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)  
TABLESPACE "SYSTEM"';
  EXECUTE IMMEDIATE 'CREATE SEQUENCE  "T_ALGORITHM"."WYNIK_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE';
  EXECUTE IMMEDIATE 'create or replace TRIGGER WYNIK_ID    
BEFORE INSERT ON wynik  
FOR EACH ROW
BEGIN  
:new.wynik_id := wynik_seq.nextval;
END;';
  v_tabela   :='DANE';
  v_obiekt_id:=0;
  SELECT COUNT(obiekt_id) INTO v_obiekty FROM pom;
  SELECT COUNT(*) INTO v_id FROM wynik;
  FOR k IN 1..v_obiekty
  LOOP
    dbms_output.put_line('v_obiekty'||k);
    SELECT DISTINCT kolumna INTO v_kolumny FROM pom WHERE OBIEKT_ID=k;
    SELECT MIN(DLUGOSC) INTO v_iteracje FROM v_wynik WHERE obiekt_id=k;
    --dbms_output.put_line(v_kolumny || 'ILE JEST KOLUMN');
    --dbms_output.put_line('Która iteracja'||v_iteracje);
    v_licznik:=1;
    v_licz_kol:=1;
     EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW TEMP AS WITH DATA AS
     ( SELECT (SELECT DLUGOSC_DECYZJI from POM where POM.OBIEKT_ID='||k||') str FROM dual
      )
    SELECT trim(regexp_substr(str, ''[^,]+'', 1, LEVEL)) str
    FROM DATA
    CONNECT BY instr(str, '','', 1, LEVEL - 1) > 0';
    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DICT as SELECT ROW_NUMBER() OVER (ORDER BY str)  row_num, str from temp where str is not null';     
    FOR i IN 1..v_iteracje
    LOOP
      IF v_iteracje>1 THEN 
        for s in (select count(str) from dict)
          LOOP
            dbms_output.put_line('tu musi wynik byc'||v_licz_kol);
            select str into v_kolumna from dict where ROW_NUM=v_licz_kol;
            EXECUTE IMMEDIATE 'insert into wynik (kolumna, obiekt) select :v_kolumna, p.obiekt_id from pom p where p.obiekt_id=:k' USING v_kolumna,k;
            v_iteracje:=v_iteracje-1;
            v_licz_kol:=v_licz_kol+1;
          END LOOP;
          v_licznik :=v_licznik +1;
        --EXECUTE IMMEDIATE 'insert into wynik (kolumna, obiekt) select t.column_name, p.obiekt_id from cols t, pom p where t.table_name=:v_tabela and t.column_id=:v_licznik and p.obiekt_id=:k' USING v_tabela,
        --v_licznik, k;
      ELSE
        select str into v_kolumna from dict where ROW_NUM=v_licz_kol;
        dbms_output.put_line(v_kolumna || 'Jestem tam' || v_licznik || v_licz_kol);
        EXECUTE IMMEDIATE 'insert into wynik (kolumna, obiekt) select :v_kolumna, p.obiekt_id from pom p where p.obiekt_id=:k' USING v_kolumna,k;
      END IF;
    END LOOP;
  END LOOP;
    EXCEPTION
WHEN NO_DATA_FOUND THEN
  v_obiekty:=v_obiekty+1;
  v_kolumny:=v_kolumny+1;
END;