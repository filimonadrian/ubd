
-- 1) crearea unei tabele permanente

CREATE TABLE studenti
(facultate char(30) DEFAULT 'Automatica si Calculatoare',
catedra char(20),
cnp number(13),
nume varchar2(30),
data_nastere date,
an_univ number(4) DEFAULT 2006,
media_admitere number(5,2) ,
discip_oblig varchar2(20) DEFAULT 'Matematica',
discip_opt varchar2(20) DEFAULT 'Fizica' ,
operator varchar2(20) DEFAULT user,
data_op date DEFAULT sysdate )
TABLESPACE bd_data,
STORAGE (initial 8M),
PCTUSED 30,
PCTFREE 20,
NOLOGGING;

-- 2) Crearea unei tabele permanente partitionate:
CREATE TABLE angajati_dep
(
depart number(2),
ecuson number(5),
nume varchar2(30),
job varchar2(20),
data_ang date,
salariu number(6)
)
PARTITION BY LIST (depart)
(
PARTITION Dep10 VALUES (10),
PARTITION Dep20 VALUES (20),
PARTITION Dep30 VALUES (30)
);

insert into angajati_dep select deptno, empno, ename, job, hiredate, sal from emp;
select * from angajati_dep partition (dep10);

-- 3) Crearea unei tabele temporare de catre userul curent:
create global temporary table emp_temp on commit delete rows as select * from emp;

-- Observatii:
-- • Datele se pastreaza in tabela doar pe perioada tranzactiei, dar tabela ramane creata si in sesiunile urmatoare.
select * from emp_temp;

insert into emp_temp select * from emp;

-- Datele pot fi sterse din tabela iar tabela poate fi stearsa din dictionar in sesiunea curenta.
drop table emp_temp;

insert into emp_temp select * from emp;


-- b) 

create global temporary table emp_temp on commit preserve rows as select * from emp;
-- Observatii:
-- Datele se pastreaza in tabela doar pe perioada sesiunii curente, dar tabela ramane creata si in sesiunile urmatoare.
select count(*) from emp_temp;

-- Datele pot fi sterse din tabela, dar tabela nu poate fi stearsa din dictionar in sesiunea curenta.
drop table emp_temp;

-- 4) Vizualizarea ROWID-rilor pentru fiecare linie din tabela:
create table emp_copy as select * from abd1.emp;
select rowid, empno, ename from emp_copy;


-- 5) Vizualizarea ROWNUM-rilor pentru fiecare linie din tabela:
select rownum, empno, ename from emp_copy where rownum<10;

-- 6) Alocarea unei extensii la o tabela:
alter tablespace users add datafile 'd:/ubd_data2.dbf' size 10M;

alter table emp_copy allocate extent(size 500k datafile 'd:/ubd_data2.dbf');

-- 7) Stergerea unei coloane dintr-o tabela:
alter table emp_copy drop column comm cascade constraints checkpoint 1000;

-- 8) Redenumirea unei coloane dintr-o tablela:
alter table emp_copy
rename column sal to salary;

-- 9) Dezactivarea unei coloane dintr-o tabela:
alter table emp_copy set unused column sal cascade constraints;

-- 10) Informatii despre tabele cu coloane dezactivate:
desc dba_unused_col_tabs;
select * from dba_unused_col_tabs;


-- 11) Stergerea din dictionar a coloanelor dezactivate dintr-o tabela:
alter table emp_copy
drop unused columns checkpoint 1000;

select * from dba_unused_col_tabs;

-- 12) Informatii despre toate tabelele din baza de date :
desc dba_tables;
select owner, tablespace_name, table_name from dba_tables where owner = 'SCOTT';

-- 13) Informatii despre tabelele create de userul curent :
desc user_tables
select instances, tablespace_name, table_name from user_tables;


-- 14) Informatii despre tabelele create de userul curent :
select table_name, partition_name, high_value from user_tab_partitions
where table_name = 'ANGAJATI_DEP'
order by partition_name;

-- 15) Informatii despre obiectele din baza de date:
desc dba_objects
select object_name, created
from dba_objects
where object_name like 'EMP%' and owner ='ABD1';

-- 16) Informatii despre obiectele create de userul current:
desc user_objects
select object_name, object_type,created, status from user_objects;

-- 17) Stergerea datelor dintr-o tabela, cu posibilitate de rollback:
delete from emp_copy where deptno=10;

-- 18) Trunchierea unei tabele (stergerea datelor dintr-o tabela, cu eliberarea spatiului ocupat de tabela si fara posibilitate de rollback):
truncate table emp_copy;

-- 19) Stergerea unei tabele din dictionar, cu stergerea tuturor referintelor pe tabela:
drop table emp_copy cascade constraints;

-- 20) Stergerea unei linii dintr-o tabela care contine duplicate folosind ROWID:
create table emp_del as select * from emp;
insert into emp_del select * from emp;
SELECT rowid, empno, ename FROM emp_del order by empno;
delete from emp_del where rowid='AAAScqAAFAAAADLAAD';
select rowid, empno, ename from emp_del order by empno;


-- 21) Stergerea unei linii dintr-o tabela care contine duplicate folosind ROWNUM:
select rownum, empno, ename from emp_del order by empno;
delete from emp_del where rownum=16;
delete from emp_del where rownum>16 and rownum<18;
delete from emp_del where rownum<15;

select rownum, empno, ename from emp_del order by empno;
-- cream o noua copie
create table emp_copy2 as select * from emp;

-- duplicam liniile in tabela emp_copy2
insert into emp_copy2 select * from emp;
select rownum, empno, ename from emp_copy2 order by empno;
delete from emp_copy2 where rownum=(select min(rownum) from emp_copy2 where empno=7566);
select rownum, empno, ename from emp_copy2 order by empno;

-- Obs. In tabela copy2_dep a fost stearsa linia cu rownum=1 (SMITH) in loc de linia cu
-- rownum=4 (JONES) !! Explicatia este ca subcererea lucreaza astfel:

select rownum from emp_copy2 where empno=7566;
select min(rownum) from emp_copy2 where empno=7566;

-- Concluzii:
-- a) Pentru stergerea manuala a liniilor se poate folosi ROWID dar Oracle nu
-- recomanda aceasta metoda.
-- b) Se poate folosi stergerea in bloc a liniilor duplicat folosind ROWNUM, in
-- anumite cazuri particulare, dar cu mare atentie. Nici aceasta metoda nu este
-- recomandata de catre Oracle.
-- c) Pentru stergerea liniilor duplicat se recomanda utilizarea executiilor ciclice din
-- PL/SQL (LOOP, FOR, WHILE, cursoare, etc).


-- 22) Stergerea unei singure linii duplicat dintr-o tabela care contine duplicate, folosind subcereri:
select * from emp_copy2 A where rowid IN (select min(rowid) from emp_copy2 B where ename='SMITH');
delete from emp_copy2 A where rowid IN (select min(rowid) from emp_copy2 B where ename='WARD');
select rownum, empno, ename from emp_copy2 order by empno;


-- 23. Stergerea liniilor duplicat dintr-o tabela care contine cate un duplicat la fiecare
-- linie, folosind subcereri:
select * from emp_copy2 A where
rowid IN (select min(rowid) from emp_copy2 B where A.empno=B.empno) order by ename;

delete from emp_copy2 A where
rowid IN (select min(rowid) from emp_copy2 B where A.empno=B.empno);

-- 24. Stergerea tuturor liniilor duplicat dintr-o tabela care contine mai multe
-- duplicate folosind subcereri:
select * from emp_copy2 A where
rowid > (select min(rowid) from emp_copy2 B where A.empno=B.empno) order by ename;

delete from emp_copy2 A where
rowid >(select min(rowid) from emp_copy2 B where A.empno=B.empno);

select rownum, empno, ename from emp_copy2 order by empno;




-- exercitii individuale

-- 1 sa se creeze linii duplicat pentru toti angajatii din tabela emp_copy.
-- sa se stearga apoi liniile duplicat din aceasta tabela
create table emp_copy as select * from abd1.emp;
insert into emp_copy select * from emp_copy;

select * from emp_copy A where
rowid > (select min(rowid) from emp_copy B where A.empno=B.empno) order by ename;

delete from emp_copy A where
rowid IN (select min(rowid) from emp_copy B where A.empno=B.empno);

-- 2 Dezactivati coloana comision din emp_copy, apoi o activati la loc
-- aratati din dictionar structura refacuta
alter table emp_copy set unused column comm cascade constraints;
select * from dba_unused_col_tabs;
alter table emp_copy add comm number(7,2);


-- 3 Sa se creeze o tabela temporara emp_temp care sa pastreze datele stocate pe
-- toata durata sesiunii curente
create global temporary table emp_temp3 on commit preserve rows as select * from emp;

