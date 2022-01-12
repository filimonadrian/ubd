

-- 1) Verificare setare parametru pentru prefixul userului comun (common user)
connect scott@bd /tiger
connect abd1@bd /tiger

show parameter common_user_prefix;

-- 2) Creare user local cu parola de conexiune la baza de date:
create user test identified by test default tablespace bd_data temporary tablespace bd_temp quota 10M on bd_data;

-- 3) Schimbarea parolei unui user
alter user test identified by pass_test;

-- 4) Creare privilegiu pentru conectare:
grant create session to test;

-- 5) Creare privilegiu pentru conectare cu ADMIN OPTION:
grant create session to test with admin option;

-- 6) Alocarea unui spatiu de dimensiune fixa/nelimitata in tablespace-ul permanent BD_DATA
-- pentru userul test:
alter user test quota 5 M on bd_data;

alter user test quota unlimited on bd_data;

-- 7) Revocarea spatiului in tablespace-ul permanent BD_DATA pentru userul test:
alter user test quota 0 M on bd_data;

-- 8) Blocarea unui user:
alter user test account lock;
conn test

-- 9) Deblocarea unui user:
alter user test account unlock;
conn test

-- 10) Vizualizarea informatiilor despre userii creati pe baza de date:
desc dba_users
select username, default_tablespace, temporary_tablespace from dba_users;

-- 11) Vizualizarea informatiilor despre spatiul alocat si spatiul utilizat de catre userii creati pe baza
-- de date:

desc dba_ts_quotas
select username, tablespace_name, max_bytes, bytes from dba_ts_quotas;

-- 12) Vizualizarea informatiilor despre userul curent:
desc user_users
select user_id, username, created, lock_date from user_users;

-- 13) Stergerea unui user din dictionar:
drop user test;
drop user test cascade;

-- B. Administrare privilegii
-- 1) Acordare de privilegii pe o tabela din schema curenta(userul curent) unui alt user:
connect scott@bd /tiger
grant select, insert, update on emp_copy to test;

-- 2) Verificare privilegii acordate:
connect abd1
select * from abd1.emp_copy where deptno=10 ;
insert into abd1.emp_copy values (1111,'Test','Student',7902, sysdate, 1000, 22, 10);
update abd1.emp_copy set sal=1500 where empno=1111;

-- 3) Crearea unei copii a unei tabele creata in alta schema:
connect abd1
grant create table to test;
connect test
create table emp_test as select * from abd1.emp_copy;
-- Obs. Cand se creeaza o tabela nu se creeaza automat si constrangerile de integritate :
connect abd1
select owner, table_name, constraint_name from dba_constraints where owner='ABD1' and table_name='EMP';
connect test
select owner, table_name, constraint_name from user_constraints where owner='TEST' and table_name='EMP_TEST';


-- 4) Revocarea unui privilegiu:
connect abd1
revoke select on emp_copy from test;
connect test
select * from abd1.emp_copy;

connect abd1
-- revocarea tuturor privilegiilor
revoke all on emp_copy from test cascade constraints;
-- Obs. Se sterg si toate constrangerile de integritate create de user folosind REFERENCES sau ALL.
-- 5) Vizualizarea privilegiilor de sistem acordate direct unui user(nu prin intermediul rolurilor) :
connect abd1
desc dba_sys_privs

select * from dba_sys_privs where grantee='TEST';

-- 6) Vizualizarea tuturor privilegiilor de sistem acordate userului curent(acordate direct sau
-- indirect prin intermediul rolurilor):
connect abd1
desc session_privs
select * from session_privs order by privilege;

-- 7) Vizualizarea tuturor privilegiilor acordate pe obiectele bazei de date:
connect abd1
desc dba_tab_privs

select grantee, owner, table_name, grantor, privilege from dba_tab_privs where grantee='TEST';

-- 8) Privilegii acordate pe anumite coloane ale unei tabele (numai insert si update):
grant insert(empno, ename) on emp_copy to test;
grant update(empno, ename) on emp_copy to test;
conn test
insert into abd1.emp_copy(empno,ename) values (1111,'Popa');
insert into abd1.emp_copy(empno,sal) values (1111,100);

update abd1.emp_copy set ename='Tache' where ename='Popa';
update abd1.emp_copy set sal=1000 where ename='Tache';


-- 9) Vizualizare privilegii acordate pe anumite coloane:
desc dba_col_privs
select grantee, owner, table_name, column_name, grantor, privilege from dba_col_privs;

-- 10) Acordare privilegii de conexiune pentru un user (pentru versiuni pana la Oracle 11g):
conn sys as sysdba;
grant connect to test;
grant create session to test;

-- 11) Creare restrictii de conexiune la instanta curenta:
alter system enable restricted session;
conn test/test

-- 12) Vizualizarea tipului de conexiune pentru userul curent:
select logins from v$instance;
alter system disable restricted session;
select logins from v$instance;
conn test


-- exercitii individuale

-- 1. Sa se arate din dictionar care sunt privilegiile de sistem acordate userului TEST

select * from dba_sys_privs where grantee='TEST';

-- 2. Aratati din dictionar care sunt userii grantificati de userul curent sau care au grantificat
-- userul curent, pe ce tabele si ce privilegii sunt acordate
select
    grantee,
    owner,
    table_name,
    grantor,
    privilege
from
    dba_tab_privs
where
    grantee='ABD1' OR grantor='ABD1';


-- session_privs - Vizualizarea tuturor privilegiilor de sistem acordate userului curent(acordate direct sau indirect prin intermediul rolurilor):
-- dba_sys_privs - Vizualizarea privilegiilor de sistem acordate direct unui user(nu prin intermediul rolurilor) :
-- dba_tab_privs - Vizualizarea tuturor privilegiilor acordate pe obiectele bazei de date:
-- dba_col_privs -  Vizualizare privilegii acordate pe anumite coloane:

-- 3. Sa se arate din dictionar doar numele tablespace-ului temporar asociat userului curent
select username, temporary_tablespace from dba_users where username='TEST'; 

