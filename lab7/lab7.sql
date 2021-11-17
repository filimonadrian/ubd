
-- structuri de stocare a datelor(cap. 9)


desc dba_tablespaces
select tablespace_name,block_size,initial_extent,min_extents, max_extents, contents, status from dba_tablespaces where tablespace_name='USERS';

-- 2) Informatii despre un tablespace, fisierul de date alocat, numarul total de blocuri si dimensiunea lor:
desc dba_data_files;
select tablespace_name, file_id, file_name, blocks, bytes from dba_data_files where tablespace_name='USERS';


-- 3) Informatii despre segmentele de tip tabela create intr-un tablespace :
desc dba_segments;
select owner,segment_name,segment_type, tablespace_name, blocks, extents from dba_segments where owner='ABD1'and segment_type='TABLE';


-- 4) Informatii despre dimensiunea extensiilor alocate unui segment:
desc dba_extents
select owner, segment_name, segment_type, tablespace_name from dba_extents where owner='ABD1' and segment_name='EMP';
select segment_name, extent_id, file_id, block_id, blocks, bytes from dba_extents where owner='ABD1' and segment_name='EMP';

-- 5) Informatii despre tablespace, fisierul de date alocat, numarul de blocuri si spatiul liber in fiecare bloc :
desc dba_free_space
select * from dba_free_space where tablespace_name='USERS';
select tablespace_name, count(*), max(blocks), sum(blocks) from dba_free_space group by tablespace_name;
select tablespace_name, blocks from dba_free_space where tablespace_name='SYSTEM';

-- 6) Unificarea spatiilor contigue dintr-un tablespace(defragmentare):
desc dba_free_space_coalesced

alter tablespace BD coalesce;
select tablespace_name,total_extents, percent_extents_coalesced from dba_free_space_coalesced;



-- Segmente de undo si sortare

-- 7) Crearea unui tablespace de undo:
create undo tablespace BD_UNDO datafile 'd:\undo_db01.dbf' size 2M;


-- 8) Crearea unui segment de undo in tablespace-ul de undo:
create rollback segment UBD_UNDO tablespace BD_UNDO storage (initial 100k next 100k optimal 4M minextents 20 maxextents 100);
-- Obs. Daca la startarea bazei de date parametrul UNDO_MANAGEMENT= AUTO atunci segmentul nu poate fi utilizat online

-- 9) Informatii din dictionar privind segmentele de undo:
desc dba_rollback_segs
select segment_name,tablespace_name,owner,status from dba_rollback_segs;

-- 10) Segmentele de undo folosite de instanta curenta:
desc v$rollname
select * from v$rollname;

-- 11) Statistici despre segmentele de undo:
desc v$rollstat
select usn, rssize, extents, status from v$rollstat;

-- 12) Informatii despre useri si sesiuni:
desc v$session
select username, sid, saddr, service_name from v$session;

-- 13) Informatii despre tranzactii( adresele tranzactiilor pot fi relationate cu sesiunile prin ses_addr):
desc v$transaction
insert into emp values (999, 'TEST','TRANZACT',1111,sysdate, 100,0,10);
select addr, xidusn, used_ublk,start_uext, start_ubafil from v$transaction;


-- 14) Informatii despre blocurile de undo folosite de tranzactia curenta:
SELECT s.username, t.xidusn, t.ubafil, t.ubablk, t.used_ublk
FROM
    v$session s,
    v$transaction t
WHERE
    s.saddr = t.ses_addr;

-- 15) Statistici privind dimensiunea spatiului de undo:
desc v$undostat
SELECT to_char(begin_time, 'dd-mm-yyyy hh:mi:ss') start_time, to_char(end_time, 'ddmm-yyyy hh:mi:ss') end_time, ((end_time-begin_time)* 24)*60 minute, undoblks FROM v$undostat;
SELECT (SUM(undoblks) / SUM ((end_time - begin_time) * 24*60*60)) nr_med_blocuri_undo_sec FROM v$undostat;


-- 16) Reducerea spatiului alocat unui segment de undo:
alter rollback segment ubd shrink to 4M;

-- 17) Stergerea din dictionar a unui segment de undo:
drop rollback segment ubd

-- 18) Informatii despre segmentele temporare de sortare (folosite in comenzile SQL de sortare):
desc v$sort_segment
select tablespace_name,max_sort_size,extent_size,max_sort_blocks from v$sort_segment;


-- 19) Informatii despre sesiuni si tablespace-ul in care se afla segmentele temporare de sortare folosite in sesiunea curenta:
desc v$tempseg_usage 
desc v$sort_usage


-- 20) Setarea zonei de memorie utilizata pentru sortare in sesiunea curenta la 10K.
alter system set sort_area_size=10240 deferred










-- exercitii individuale


-- 1) Sa se arate din dictionar care sunt indecsii creati pe tabelele din userul ABD1, in ce tabele sunt creati si cate blocuri le sunt alocate
select owner, blocks, segment_name, segment_type, tablespace_name from dba_segments where owner='ABD1' and segment_type='INDEX';


-- 2) Sa se arate din dictionar care este spatiul liber, ca numar de blocuri, in tablespace-ul permanent asignat userului curent
select
    tablespace_name,
    sum(blocks) free_blocks
from
    dba_free_space
where
    tablespace_name = (select default_tablespace from dba_users where username = user) group by tablespace_name;


-- 3) Faceti o lista cu numele segmentului asociat cheii primare a tabelei EMP, numele fisierului in care este stocat si dimensiunea extensiei in numar de blocuri
select a.segment_name, a.blocks, b.file_name
from dba_extents a, dba_data_files b
where
    a.file_id = b.file_id AND a.segment_name = 'EMP';




-- exercitii din laboratoarele altor grupe

-- 1) Sa se arate din dictionar care sunt tabelele partitionate create de userul SYSTEM
select tablespace_name, partition_name from dba_segments where segment_type LIKE 'TABLE PARTITION' and owner='SYSTEM';

-- 2) Aratati din dictionar dimensiunea in blocuri si bytes a indexului creat pentru cheia primara a tabelei emp
select bytes, blocks, segment_name
from user_segments
where segment_name in (SELECT constraint_name from user_constraints where table_name = 'EMP' and constraint_type = 'P');

-- 3) Aratati din dictionar numele si numarul total de blocuri libere din tablespace-ul permanent asignat userului curent
select
    tablespace_name,
    sum(blocks) free_blocks
from
    dba_free_space
where
    tablespace_name = (select default_tablespace from dba_users where username = user) group by tablespace_name;
