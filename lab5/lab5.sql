spool c:\users\adrian\documents\ubd\spool_ubd\spool_ubd_lab5_3nov2021
set lines 200
set pages 100

select to_char(sysdate, ’dd-mm-yyyy hh:mi:ss’) from dual;

--- incepe sesiune
insert into login_lab_ubd values( 'Filimon Adrian', '342C2', 'Lab5', user, sysdate, null, null);


-- 1 informatii despre fisierele de log si starea lor
desc v$logfile
select * from v$logfile;

-- 2 Informatii legate de modul de lucru al bazei de date ( cu arhivare sau fara arhivare a fisierelor de
-- log, data cand au fost resetate fisierele de log, etc.)

desc v$database
select name, log_mode, resetlogs_time from v$database;

-- 3) Informatii legate de starea instantei, a grupului curent din fisierele de log si a secventei curente:

desc v$thread
select groups, current_group#, sequence#, instance, status from v$thread;

-- 4) informatii despre grupuri si membri in cadrul grupurilor:

desc v$log
select group#, members, bytes, archived, status from v$log;

-- !!!!
-- 5) adaugarea unui membru la un grup (se creeaza automat in SO un nou fisier de log)
alter database add logfile member 'D:\log2.rdo' to group 1;

-- 6) resetarea unui grup dintr-un fisier de log(care nu este grup curent)
alter database clear logfile group 2;

-- 7) relocarea unui fisier de log cu baza de date online(trebuie ca fisierul 
-- sa nu fie in grupul curent sau sa exista o copie in noua locatie)
alter database rename file 'D:\log2.rdo' to 'D:\new_log.rdo';

-- 8 stergerea unui membru dintr-un grup:
--  - se verifica starea fisierului care va fi sters
select * from v$logfile;
--  - se sterge fisierul de log(trebuie sa nu fie in grupul curent)
alter database drop logfile member 'D:\new_log.rdo';
-- daca fisierul face parte din grupul curent, se face switch pe urmatorul grup
    alter system switch logfile;
    alter database drop logfile member 'D:\new_log.rdo';
    select * from v$logfile;

-- 9) informatii legate de modul de lucru al instantei
desc v$instance
select instance_name, status, archiver from v$instance;

-- 10) informatii despre istoricul fisierelor de log
desc v$loghist
select * from v$loghist;


--- exercitii individuale

-- 1) aratati din dictionar numele bazei de date curente, care sunt fisierele
-- de control asignate si data cand au fost create
show PARAMETER CONTROL_FILES
select name, created, controlfile_created from v$database;

-- 2) Aratati din dictionar numarul maxim de fisiere temporare care se pot crea
-- pentru baza de date curenta
select * from v$parameter where name = 'db_files'
select * from v$controlfile_record_section where type='TEMPORARY FILENAME';

-- 3) Faceti o lista cu grupurile fisierelor de log, fisierele membru, calea unde
-- sunt create fizic si dimensiunile lor in MB
select GROUP#, MEMBER from v$logfile;















-- 4) aratati din dictionar numarul de inregistrari care pot fi stocate si numarul
-- de inregistrari utilizate pentru parametrii aferenti fisierelor de date si
-- tablespace-urile create pe baza de date curenta
select * from v$controlfile_record_section where type='TABLESPACE' OR type = 'DATAFILE';

-- 5) Faceti o lista cu grupurile fisierelor de log, fisierele membru, calea unde
-- sunt create fizic si dimensiunile lor in MB
select
    a.group#,
    a.member,
    b.bytes,
    b.members
FROM
    v$logfile a,
    v$log b
wHERE
    a.group# = b.group#;

select * from v$logfile;
select bytes from v$log;



-- 6) aratati din dictionar numele instantei curente si grupurile fisierelor log
-- aflate in starea 'OPEN'

select
    a.instance_name,
    b.groups,
    b.current_group#,
    b.sequence#,
    b.status
FROM
    v$instance a,
    v$thread b
wHERE
    a.instance_name = b.instance;

select instance, groups, current_group#, sequence#, instance, status from v$thread;
