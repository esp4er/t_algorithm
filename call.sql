create or replace procedure call(v_resetno number) is
v_inc number;
v_dummy number;
begin
select -(historia_seq.nextval-v_resetno)-1 into v_inc from dual;
execute immediate 'alter sequence historia_seq increment by '||v_inc;
select historia_seq.nextval into v_dummy from dual;
execute immediate 'alter sequence historia_seq increment by 1';
end;