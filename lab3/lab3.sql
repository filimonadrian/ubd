SELECT constraint_name,table_name, column_name FROM user_cons_columns;

-- Vizualizare structura tabelara
desc user_tab_columns

select table_name,column_name,data_type from user_tab_columns
where table_name='EMP';


select owner,index_name,index_type,table_name from dba_indexes where owner in ('ABD1');


-- 1. Sa se creeze unicitate pe o coloana din tabela dept apoi sa se verifice
-- in dictionar daca a fost creata constrangerea.
alter table dept add constraint unique_dname unique(dname);
select owner,constraint_name,constraint_type, table_name from user_constraints;


-- 2. Sa se creeze un index pe tabela emp apoi sa se faca o lista cu numele
-- indecsilor creati pe tabelele din userul curent, tipul lor si numele
-- tabelelor pe care au fost creati.

select owner,index_name,index_type,table_name from dba_indexes where owner in ('ABD1');
create index index_emp on emp(ename);


-- 3. Sa se faca o lista cu numele userului curent si tablespace-ul in care userul isi creeaza
-- tabelele.

select username, default_tablespace from user_users where username in ('ABD1');
select username, default_tablespace, temporary_tablespace from user_users where username in ('ABD1');


-- 4. Aratati din dictionar numele bazei de date si data cand au fost create fisierele de control
-- asignate la baza de date curenta.

desc v$database;
select name, controlfile_created from v$database;


-- 5. Aratati din dictionar care este dimensiunea standard a blocului de date pentru baza de date
-- curenta.

desc dba_tablespaces;
select tablespace_name, block_size from dba_tablespaces;