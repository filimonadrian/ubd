
-- 1) Crearea unui tablespace de undo:
create undo tablespace BD_UNDO datafile 'd:\undo_db01.dbf' size 2M;

-- 2) Crearea unui segment de undo in tablespace-ul de undo:
create rollback segment UBD_UNDO tablespace BD_UNDO storage (initial 100k next 100k optimal 4M minextents 20 maxextents 100);

-- 3) Informatii din dictionar privind segmentele de undo:
desc dba_rollback_segs

column segment_name format a30
column tablespace format a30
select segment_name,tablespace_name,owner,status from dba_rollback_segs;

-- 4) Segmentele de undo folosite de instanta curenta:
desc v$rollname
select * from v$rollname;

-- 5) Statistici despre segmentele de undo:
desc v$rollstat
column rssize format a30
select usn, rssize, extents, status from v$rollstat;

-- 6) Informatii despre useri si sesiuni:
desc v$session
column username format a30
column saddr format a30
column service_name format a30
select username, sid, saddr, service_name from v$session;

-- 7) Informatii despre tranzactii( adresele tranzactiilor pot fi relationate cu sesiunile prin ses_addr):

desc v$transaction
-- ADDR – adresa sesiunii
-- XIDUSN – nr. segmentului de undo
-- USED_UBLK – nr. de blocuri de undo generate de tranzactie
-- START_UEXT- extensia segmentului de undo pentru care tranzactia a inceput scrierea
-- START_UBAFIL – fisierul de undo in care tranzactia curenta a inceput scrierea
insert into emp values (9999, 'TEST1','TRANZACT',1111,sysdate, 100,0,10);
select addr, xidusn, used_ublk,start_uext, start_ubafil from v$transaction;


-- 8) Informatii despre blocurile de undo folosite de tranzactia curenta:
SELECT
    s.username,
    t.xidusn,
    t.ubafil,
    t.ubablk,
    t.used_ublk
FROM
    v$session s,
    v$transaction t
WHERE
    s.saddr = t.ses_addr;

-- 9) Statistici privind dimensiunea spatiului de undo:
desc v$undostat
SELECT to_char(begin_time, 'dd-mm-yyyy hh:mi:ss') start_time, to_char(end_time,'ddmm-yyyy hh:mi:ss') end_time, ((end_time-begin_time)* 24)*60 minute, undoblks FROM v$undostat;
SELECT (SUM(undoblks) / SUM ((end_time - begin_time) * 24*60*60)) nr_med_blocuri_undo_sec FROM v$undostat;

-- 10) Reducerea spatiului alocat unui segment de undo:
alter rollback segment ubd shrink to 4M;

-- 11) Stergerea din dictionar a unui segment de undo:
drop rollback segment ubd;

-- 12) Informatii despre segmentele temporare de sortare (folosite in comenzile SQL de sortare):
desc v$sort_segment
select tablespace_name,max_sort_size,extent_size,max_sort_blocks from v$sort_segment;

-- 13) Informatii despre sesiuni si tablespace-ul in care se afla segmentele temporare de sortare folosite in sesiunea curenta:
desc v$tempseg_usage ( v$sort_usage)
select username,user,tablespace,contents,extents,blocks from v$tempseg_usage;

-- 14) Setarea zonei de memorie utilizata pentru sortare in sesiunea curenta la 10K.
alter system set sort_area_size=10240 deferred;



---- individuale
-- 1. Sa se faca o lista cu numele, marimea in bytes si
-- starea segmentelor de undo din sesiunea curenta
select
    a.name,
    b.extents,
    b.rssize,
    b.status
from
    v$rollname a,
    v$rollstat b
where
    a.usn = b.usn AND b.status = 'ONLINE';

-- var 2
select
    a.tablespace_name,
    a.free_blocks,
    b.name
from
    v$sort_segment a,
    v$datafile b
where a.segment_file = d.file#;

-- 2. Sa se faca o lista cu numele  tablespace-ului folosit pentru segmentele
-- temporare de sortare din sesiunea curenta, numarul de blocuri nealocate la
-- nicio sortare si numele fisierului asignat
select
    a.tablespace_name,
    a.free_blocks,
    b.file_name
from
    v$sort_segment a,
    dba_temp_files b
where
    a.tablespace_name = b.tablespace_name;

-- 3. Sa se creeze un tablespace de undo UNDO_LAB. Sa se faca apoi o lista cu numele
-- segmentelor de rollback, fisierele in care sunt create segmentele si starea lor

create undo tablespace UNDO_LAB datafile 'c:\undo_lab.dbf' size 2M;
select
    b.file_name,
    a.file_id,
    a.segment_name,
    a.tablespace_name,
    a.segment_id,
    a.status
from
    DBA_ROLLBACK_SEGS a,
    DBA_DATA_FILES b
where
    a.tablespace_name = b.tablespace_name;







-- 1. Sa se faca o lista cu numele, marimea in bytes si
-- starea segmentelor ONLINE din sesiunea curenta
select
    a.name,
    b.extents,
    b.rssize,
    b.status
from
    v$rollname a,
    v$rollstat b
where
    a.usn = b.usn AND b.status = 'ONLINE';


-- 2. Sa se faca o lista cu numele, tipul si starea tablespace-ului folosit pentru
-- segmentele temporare de sortare din sesiunea curenta, numarul maxim
-- de blocuri de sortare alocate fiecarui segment temporar

select
    a.tablespace_name,
    b.status,
    b.contents,
    a.max_sort_blocks
from
    v$sort_segment a,
    dba_tablespaces b
where
    a.tablespace_name = b.tablespace_name;


-- 3. Sa se faca o operatie de inserare in tabeta dept, apoi sa se faca o lista cu
-- userul curent, adresa sesiunii, adresa tranzactiei, numele si numarul segmentului
-- de rollback folosit in sesiunea curenta
SELECT
    s.username,
    s.saddr,
    s.taddr,
    r.name,
    t.xidusn,
    t.ubafil,
    t.ubablk,
    t.used_ublk
FROM
    v$session s,
    v$transaction t,
    v$rollname r
WHERE
    s.saddr = t.ses_addr AND
    t.xidusn = r.usn;
