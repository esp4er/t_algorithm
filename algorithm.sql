create or replace PROCEDURE "ALGORYTM"(
    p_par_uzyt      VARCHAR2,
    p_tabela        VARCHAR2 DEFAULT 'DANE',
    p_nazwa_kolumny VARCHAR2,
    p_id_kolumny    VARCHAR2,
    p_id_wiersza    VARCHAR2,
    p_koniec    IN OUT VARCHAR2,
    p_lista_kol IN OUT VARCHAR2)
IS
  v_ile           NUMBER;
  v_najczestszy   NUMBER;
  v_sprawdz       NUMBER;
  v_wartosc       VARCHAR2(2000);
  v_ile_kolumn    NUMBER;
  v_licznik       NUMBER :=0;
  v_licznik1      NUMBER :=0;
  v_nazwa_kolumny VARCHAR2(30);
  v_id_kolumny    NUMBER;
  v_wynik_pomoc   NUMBER;
  v_min           NUMBER;
  v_ile2          NUMBER;
  v_wynik         VARCHAR2(2000);
  v_lista_kol     VARCHAR2(2000);
  v_kol_name      VARCHAR2(2000);
  v_id_col        NUMBER;
  v_kolumna       VARCHAR2(2000);
  v_ktora_kolumna NUMBER;
  v_temp_sprawdz  NUMBER;
  v_temp_kolumna  VARCHAR2(2000);
BEGIN
  v_licznik  := 0;
  --pobranie nazw kolumn z tabeli dane
  SELECT COUNT(*)
  INTO v_ile_kolumn
  FROM cols
  WHERE TABLE_NAME=upper(p_tabela);
  FOR i IN
  (SELECT COLUMN_NAME,
    COLUMN_ID
  FROM cols
  WHERE TABLE_NAME      =upper(p_tabela)
  AND (p_nazwa_kolumny IS NULL
  OR p_nazwa_kolumny    = column_name)
  ORDER BY COLUMN_ID
  )
  LOOP
    IF v_ile_kolumn - v_licznik <= 2 THEN
      EXIT;
    END IF;
    execute immediate 'SELECT COUNT(*) INTO :v_ile2 FROM dane1' INTO v_ile2;
    IF v_ile2 = 0 THEN
      dbms_output.put_line('TC1 '||i.COLUMN_NAME);
      EXECUTE immediate 'SELECT ' || i.COLUMN_NAME || ' FROM ' || 'DANE' || ' where id=:p_id_wiersza' INTO v_wartosc USING p_id_wiersza;
    ELSE
      dbms_output.put_line('column_namE'||i.COLUMN_NAME);
      dbms_output.put_line('p_id_wiersza'||p_id_wiersza);
      --SELECT '' || i.COLUMN_NAME || '' into v_wartosc from dane1 where id='' || p_id_wiersza || '';
      v_temp_kolumna:=i.COLUMN_NAME;
      IF i.COLUMN_NAME is NULL then
        i.COLUMN_NAME:=v_temp_kolumna;
        EXECUTE immediate 'SELECT ' || i.COLUMN_NAME || ' FROM ' || 'DANE1' || ' where id=:p_id_wiersza' INTO v_wartosc USING p_id_wiersza;   
      ELSE
        --IF i.COLUMN_NAME='COLOR' AND p_id_wiersza = 5 THEN
        -- EXECUTE immediate 'CREATE TABLE RSDADM.DANE2 AS SELECT * FROM RSDADM.DANE1';
        --END IF;
        --delete dane2;
        --insert into dane2 SELECT * FROM DANE1;
        --commit;
        EXECUTE immediate 'SELECT ' || i.COLUMN_NAME || ' FROM ' || 'DANE1' || ' where id=:p_id_wiersza' INTO v_wartosc USING p_id_wiersza; 
      END IF;
    END IF;
    v_sprawdz          := NULL;
    IF p_nazwa_kolumny IS NOT NULL THEN --tylko laduje podtabele do dane1
      DELETE wyniki;
      IF v_ile2 = 0 THEN --pierwsze przejście na podtabele to biorę dane z dane
        dbms_output.put_line('dodaje dane z DANE do DANE1');
        EXECUTE immediate 'insert into dane1 SELECT * FROM DANE WHERE ' || p_nazwa_kolumny || '= :v_wartosc' USING v_wartosc;
        dbms_output.put_line('Nazwa kolumny na początku'||p_nazwa_kolumny);
        EXECUTE IMMEDIATE 'alter table dane1 drop column ' || p_nazwa_kolumny; 
        EXECUTE IMMEDIATE 'alter table dane2 drop column ' || p_nazwa_kolumny; 
      ELSE --dla kolejnych już z dane1
        dbms_output.put_line('dodaje dane z DANE1 do DANE2');
        EXECUTE immediate 'delete dane2';
        EXECUTE immediate 'insert into dane2 SELECT * FROM DANE1';
        EXECUTE immediate 'delete dane1';
        EXECUTE immediate 'insert into dane1 SELECT * FROM DANE2 WHERE ' || p_nazwa_kolumny || '= :v_wartosc' USING v_wartosc;
        EXECUTE IMMEDIATE 'alter table dane1 drop column ' || p_nazwa_kolumny; 
        EXECUTE IMMEDIATE 'alter table dane2 drop column ' || p_nazwa_kolumny; 
      /*
        dbms_output.put_line('TC');
        FOR k IN
        (SELECT * FROM cols WHERE table_name='DANE1' 
        and COLUMN_NAME <> p_nazwa_kolumny 
        ORDER BY column_id
       )
       LOOP
          dbms_output.put_line('TC1');
          --EXECUTE immediate 'SELECT ' || k.column_name || ' FROM ' || 'DANE1' || ' where rownum=1' INTO v_wartosc ;
          EXECUTE immediate 'SELECT ' || k.COLUMN_NAME || ' FROM ' || 'DANE1' || ' where id=:p_id_wiersza' INTO v_wartosc USING p_id_wiersza;
          dbms_output.put_line('usuwam z DANE1 zbędne dane korzystając z kolumny ' || k.COLUMN_NAME || ' i wartości ' || v_wartosc);
          EXECUTE immediate 'delete DANE1 WHERE ' || k.COLUMN_NAME || '<> :v_wartosc' USING v_wartosc;
          IF SQL%rowcount <> 0 THEN --czyli jak usunąlem jakiś wiersz to jest ok bo tabela się zmniejszyla i moge szukac na mniejszej
            IF instr(p_lista_kol ||',',k.COLUMN_NAME) = 0 THEN
            p_lista_kol   := p_lista_kol || ',' || k.COLUMN_NAME;
            END IF;
            EXIT;
          ELSE
            dbms_output.put_line('nic nie usunąlem ide do kolejnej kolumny');
            --p_koniec := 'T';
            --RETURN;
          END IF;
          v_licznik1 := v_licznik1 +1;
          dbms_output.put_line('v_ile_kolumn - v_licznik1='||TO_CHAR(v_ile_kolumn - v_licznik1));
          IF v_ile_kolumn - v_licznik1 <= 2 THEN --a jak nie usunąlem nic to sprawdzam czy czasem nie jestem już na kolumnie z wynikiem co oznacza że zostala nam tabela z wszystkimi takimi samymi danymi we wszystkich wierszach i kolumnach oprócz wyniku i nie mamy szansy jej zmiejszyć czyli ciągle byśmy przetwarzali tą samą tabelę czyli tutaj kończy z informacją iż nie osiagnie się nigdy pożadanego efektu
            --dbms_output.put_line('nie mogę już zmnieszyć tabeli czyli warunki nigdy nie będę spenione! KONIEC!');
            p_koniec := 'T';
            RETURN;
          END IF;
        END LOOP;
      */
      END IF;
      algorytm( p_par_uzyt => p_par_uzyt, p_tabela => 'DANE1', p_nazwa_kolumny => NULL, p_id_kolumny => NULL, p_koniec => p_koniec, p_id_wiersza => p_id_wiersza, p_lista_kol => p_lista_kol);
      IF p_koniec = 'T' THEN
        RETURN;
      END IF;
    END IF;
    --ile wierszy w podtabeli
    dbms_output.put_line('SELECT COUNT(*)                           
FROM ' || upper(p_tabela) || ' WHERE ' || i.COLUMN_NAME || '= :v_wartosc');
    EXECUTE immediate 'SELECT COUNT(*)                           
FROM ' || upper(p_tabela) || ' WHERE ' || i.COLUMN_NAME || '= :v_wartosc' INTO v_ile USING v_wartosc;
    dbms_output.put_line('v_ile' || v_ile);
    --najczestszy wynik w podtabeli
    EXECUTE IMMEDIATE 'SELECT decyzja,ile from (                            
(SELECT decyzja,COUNT(*) ile FROM ' || upper(p_tabela) || ' WHERE ' || i.COLUMN_NAME || '=:v_wartosc GROUP BY decyzja                             
)                           
ORDER BY 2 DESC)                           
where rownum =1' INTO v_wynik,
    v_najczestszy USING v_wartosc;
    dbms_output.put_line('v_najczestszy' || v_najczestszy);
    v_sprawdz := v_ile - v_najczestszy;
    dbms_output.put_line('v_sprawdz='||v_sprawdz);
    select column_id into v_ktora_kolumna from cols WHERE TABLE_NAME=upper(p_tabela) and column_name=i.column_name;
    --execute immediate 'INSERT INTO test (decyzja, kolumna, dlugosc_decyzji, obiekt_id) select '||i.column_name||' from dane where wynik='||v_wynik||' and id='||p_id_wiersza||'';
    IF v_sprawdz = 0 OR v_sprawdz <= p_par_uzyt THEN
        p_koniec     := 'T';
        p_lista_kol  := p_lista_kol || ',' || i.column_name;
        v_kolumna:=i.column_name||' ';
        select column_id into v_ktora_kolumna from cols WHERE TABLE_NAME=upper(p_tabela) and column_name=i.column_name;
        --EXECUTE IMMEDIATE 'INSERT into POM (decyzja, kolumna, dlugosc_decyzji, obiekt_id) values ('||v_wynik||','||v_ktora_kolumna||', :p_lista_kol,'||p_id_wiersza||')'using p_lista_kol;
        EXECUTE IMMEDIATE 'INSERT into POM (decyzja, kolumna, dlugosc_decyzji, obiekt_id) values (:v_wynik,:v_ktora_kolumna,:p_lista_kol,:p_id_wiersza)' using v_wynik, v_ktora_kolumna, p_lista_kol, p_id_wiersza;
        dbms_output.put_line('Która kolumna'||v_ktora_kolumna);
        IF v_sprawdz  = 0 THEN
          dbms_output.put_line('OK! zgodny z 0 dla ' || ltrim(p_lista_kol,',') || ' i wyniku ' || v_wynik || ' startując od wiersza gdzie ID=' || p_id_wiersza);
        ELSE
          dbms_output.put_line('OK! zgodny z parametrem użytkownika dla ' || ltrim(p_lista_kol,',') || ' i wyniku ' || v_wynik || ' startując od wiersza gdzie ID=' || p_id_wiersza );
          END IF;
        RETURN;
    END IF;
    dbms_output.put_line('v_licznik ' || v_licznik);
    v_licznik := v_licznik + 1;
    INSERT
    INTO wyniki
      (
        kolumna,
        wynik,
        id_kolumny
      )
      VALUES
      (
        i.column_name,
        v_sprawdz,
        i.column_id
      );
    COMMIT;
  END LOOP;
      /*IF v_sprawdz >=p_par_uzyt THEN
        SELECT MIN(wynik) into v_temp_sprawdz from wyniki;
        dbms_output.put_line('v_temp ' || v_temp_sprawdz);
        IF v_temp_sprawdz <=p_par_uzyt THEN
          select MIN(ID_KOLUMNY) into v_id_kolumny from wyniki where WYNIK=v_temp_sprawdz;
          dbms_output.put_line('v_id_kolumny ' || v_id_kolumny);  
          select DISTINCT kolumna into v_nazwa_kolumny from wyniki where wynik=v_temp_sprawdz and id_kolumny=v_id_kolumny;
          dbms_output.put_line('v_nazwa_kolumny ' || v_nazwa_kolumny);
          v_temp_sprawdz:=0;
          --select column_id into v_ktora_kolumna from cols where table_name='DANE' and column_name=v_nawa_kolumny;
          p_lista_kol  := p_lista_kol || ',' || v_nazwa_kolumny;
          --EXECUTE IMMEDIATE 'INSERT into POM (decyzja, kolumna, dlugosc_decyzji, obiekt_id) values (:v_wynik,:id_kolumny,:p_lista_kol,:p_id_wiersza)' using v_wynik, v_id_kolumny, p_lista_kol, p_id_wiersza;
          --EXECUTE IMMEDIATE 'INSERT into POM (decyzja, kolumna, dlugosc_decyzji, obiekt_id) values (v_wynik, v_id_kolumny, p_lista_kol, p_id_wiersza)' using p_lista_kol;
          RETURN;
          --przetworz( p_par_uzyt => v_temp_sprawdz, p_tabela => 'DANE1', p_nazwa_kolumny => v_nazwa_kolumny, p_id_kolumny => v_id_kolumny, p_koniec => p_koniec, p_id_wiersza => p_id_wiersza, p_lista_kol => p_lista_kol);
        END IF;
    END IF;
    */
  v_licznik := 1;
  --wybranie która kolumna jest najbliżej parametru użytkownika
  FOR i IN
  (SELECT * FROM wyniki ORDER BY id_kolumny
  )
  LOOP
    IF v_licznik       = 1 THEN
      v_id_kolumny    := i.id_kolumny;
      v_nazwa_kolumny := i.kolumna;
      v_wynik_pomoc   := ABS(i.wynik - p_par_uzyt);
      --dbms_output.put_line('v_wynik_pomoc='||v_wynik_pomoc );
    ELSE
      --dbms_output.put_line('v_wynik_pomoc='||v_wynik_pomoc );
      --dbms_output.put_line('ABS(i.wynik - p_par_uzyt)='||ABS(i.wynik - p_par_uzyt));
      IF v_wynik_pomoc   > ABS(i.wynik - p_par_uzyt) THEN --różnica z porzedniego przebiegu jest większa więc ustawiamy się na tej bieżącej kolumnie
        v_nazwa_kolumny := i.kolumna;
        v_id_kolumny    := i.id_kolumny;
        v_wynik_pomoc   := ABS(i.wynik - p_par_uzyt);
      END IF;
    END IF;
    v_licznik := v_licznik +1;
  END LOOP;
  dbms_output.put_line('v_wynik_pomoc_najniższy='||v_wynik_pomoc || ' dla kolumny ' || v_nazwa_kolumny);
  --sprawdzenie czy czasem kolumna o najmiejszym wyniku nie jest bliżej 0 niż ta ktróą wcześniej wybraliśmy z parametru użytkownika
  SELECT MIN(wynik)
  INTO v_min
  FROM wyniki;
  IF v_min <= v_wynik_pomoc THEN
    FOR j IN
    (SELECT kolumna,
      id_kolumny
    FROM wyniki
    WHERE wynik = v_min
    ORDER BY id_kolumny ASC
    )
    LOOP
      v_nazwa_kolumny := j.kolumna;
      v_id_kolumny    := j.id_kolumny;
      EXIT;
    END LOOP;
  END IF;
  IF instr(p_lista_kol ||',',v_nazwa_kolumny) = 0 THEN
    p_lista_kol:= p_lista_kol || ',' || v_nazwa_kolumny;
  END IF;
  algorytm( p_par_uzyt => p_par_uzyt, p_tabela => 'DANE1', p_nazwa_kolumny => v_nazwa_kolumny, p_id_kolumny => v_id_kolumny,p_koniec =>p_koniec, p_id_wiersza => p_id_wiersza, p_lista_kol => p_lista_kol);
END;