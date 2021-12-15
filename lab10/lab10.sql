
-- 1) Crearea unui index de tip B-Tree:

create index abd1.emp_name_idx
on abd1.emp(JOB)
    pctfree 30
    storage(initial 200k next 200k
    pctincrease 0 maxextents 50)
    tablespace bd_data;


-- 2) Crearea unui index de tip BITMAP:
create bitmap index abd1.dept_name_idx
on
    abd1.dept(dname)
    pctfree 30
    storage(initial 200k next 200k
    pctincrease 0 maxextents 50)
    tablespace bd_data;


-- 3) Alocarea unei extensii pentru un index de tip B-Tree:
alter tablespace users add datafile 'd:/index01.dbf' size 10M;
alter index emp_name_idx allocate extent (size 200k datafile 'd:/index01.dbf');

-- Obs. Dupa ce se aloca o extensie unui index fisierul respectiv nu se poate sterge.
-- Trebuie sters mai intai indexul.
alter tablespace users drop datafile 'd:/index01.dbf';

-- 4) Eliberarea spatiului neutilizat pentru un index de tip B-Tree:
alter index emp_name_idx deallocate unused;

-- 5) Mutarea unui index in alt tablespace:
alter index emp_name_idx rebuild tablespace system;

-- 6) Defragmentarea blocurilor unui index:
alter index emp_name_idx coalesce;


-- 7) Informatii din dictionar despre indecsi:
desc dba_indexes

select index_name, index_type, table_name, status from dba_indexes where owner='ABD1';


-- 8) Informatii din dictionar despre coloanele indecsilor:
desc dba_ind_columns

select index_name, table_owner, table_name, column_name
from dba_ind_columns
where index_owner='ABD1';


-- 9) Startarea si stoparea monitorizarii unui index:
alter index emp_name_idx monitoring usage;

-- 10) Informatii din dictionar despre indecsii monitorizati:
desc v$object_usage
select * from v$object_usage;


-- 11) Startarea analizei structurii unui index (se populeaza view-ul INDEX_STATS cu
--  informatii despre index):
analyze index emp_name_idx validate structure;


-- 12) Informatii din dictionar despre starea indecsilor:
desc index_stats

select name, blocks, used_space, pct_used, distinct_keys, lf_rows, del_lf_rows
from index_stats;

-- 13) Stergerea unui index din dictionar:
drop index emp_name_idx;

---- exercitii


-- 1) Sa se creeze o copie a tabelei EMP apoi sa se creeze un index pe coloanele deptno si empno 
-- din tabela copie. Verificati in dictionar componenta indexului.

CREATE TABLE emp_copie AS SELECT * FROM EMP;

CREATE INDEX deptno_emp_copie_i 
ON emp_copie(deptno);
CREATE INDEX empno_emp_copie_i 
ON emp_copie(empno);

SELECT 
    index_name,
    index_type,
    visibility,
    status
FROM
    all_indexes
WHERE
    table_name = 'EMP_COPIE';

-- 2) Sa se creeze un nou fisier de date cu dimensiunea de 1MB. In acest fisier sa se faca o extensie 
-- de 100K pentru indexul creat.

alter tablespace BD_DATA
add datafile 'D:/index03.dbf' size 1M;
alter index deptno_emp_copie_i allocate extent (size 100k datafile 'D:/index03.dbf');


-- 3) Verificati in dictionar numarul de blocuri alocate indexului si care este procentul utilizat din 
-- spatiul alocat.
SELECT LEAF_BLOCKS, SAMPLE_SIZE FROM ALL_INDEXES WHERE INDEX_NAME = 'DEPTNO_EMP_COPIE_I';
select name, blocks, (used_space/btree_space)*100 percent_used from index_stats where name='DEPTNO_EMP_COPIE_I';

-- 4) Faceti o lista cu numele instantei curente, numele indecsilor si tabelele aferente.

select b.instance_name, c.index_name, a.table_name
from user_tables a, v$instance b, dba_ind_columns c
where b.instance_number = a.instances and a.table_name = c.table_name;


-- 5) Monitorizati indexul creat si verificati in dictionar data si ora cand a inceput monitorizarea
alter index deptno_emp_copie_i monitoring usage;
select start_monitoring from v$object_usage where index_name = 'DEPTNO_EMP_COPIE_I';


