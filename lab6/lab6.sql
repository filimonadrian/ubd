-- remove tablespaces:
DROP TABLESPACE <tablespace_name> INCLUDING CONTENTS AND DATAFILES;

-- 1) crearea unui tablespace permanent
-- a)
create tablespace ubd_data1 datafile 'd:/ubd_data1.dbf' size 10m extent management local uniform size 128k;

-- b) 
create tablespace ubd_data2 datafile 'd:/ubd_data2.dbf' size 10M;

-- extinderea spatiului alocat unui tablespace
-- a) autoextensie
alter database datafile 'd:/ubd_data1.dbf' autoextend on next 2M;

-- b) marime fixa
alter database datafile 'd:/ubd_data1.dbf' resize 5M;

-- 3) Adaugarea unui nou fisier de date la un tablespace:
alter tablespace ubd_data1 add datafile 'd:/ubd_data11.dbf' size 10M;

-- 4) Informatii despre tablespace-uri create pe baza de date:
desc dba_tablespaces
select tablespace_name, block_size,status from dba_tablespaces;



-- 1) Informatii despre tablespace-uri create pe baza de date(preluate din view):
desc v$tablespace
select * from v$tablespace;

-- 2) Informatii despre tablespace-uri si fiserele de date asignate (la nivelul bazei de date):
desc dba_data_files;
select tablespace_name,file_name,status from dba_data_files;

-- 3) Informatii despre fisierele de date asignate bazei de date:
desc v$datafile
select file#, name, creation_time,status, enabled from v$datafile;


-- 4) Informatii despre fisierele de date temporare create pe baza de date:
desc dba_temp_files
select file_name,tablespace_name, status from dba_temp_files;

-- 5) Informatii despre fisierele temporare create pe baza de date (preluate din view):
desc v$tempfile
select file#,name, creation_time, status from v$tempfile;

-- 6) Informatii despre parametrii bazei de date:
desc database_properties;
select * from database_properties;

-- 7) Informatii despre tablespace-urile alocate userilor creati pe baza de date:
desc dba_users
select username, default_tablespace, temporary_tablespace from dba_users;

-- 8) Informatii despre spatiul alocat si spatiul utilizat de catre useri in tablespace-uri:
desc dba_ts_quotas
select tablespace_name, username, max_bytes, bytes from dba_ts_quotas;


-- 9) Informatii despre userul curent:
desc user_users
select user_id, username, created, lock_date from user_users;


-- 10) Crearea unui tablespace temporar:
create temporary tablespace ubd_temp2 tempfile 'd:\ubd_temp1.dbf' size 10m extent management local uniform size 2M;

-- 11) Setare tablespace temporar ca default:
alter database default temporary tablespace ubd_temp2;

-- 12) Verificare in dictionar ce tablespace temporar este setat ca default:
select * from database_properties where property_name = 'DEFAULT_TEMP_TABLESPACE';

-- 13) Schimbare stare tablespace permanent ca READ ONLY:
alter tablespace ubd_data1 read only;

-- 14) Schimbare stare tablespace permanent ca READ WRITE:
alter tablespace ubd_data1 read write;
-- Verificare:
select tablespace_name,block_size, status from dba_tablespaces where tablespace_name='UBD_DATA1';

-- 15) Verificare in dictionar starea unui tablespace:
select tablespace_name, status from dba_tablespaces where tablespace_name='UBD_TEMP';

-- 16) Schimbare stare tablespace permanent ca OFFLINE/ONLINE:
alter tablespace ubd_data1 offline;

-- Verificare:
select tablespace_name, status from dba_tablespaces where tablespace_name='UBD_DATA1';

alter tablespace ubd_data1 online;

-- 17) Mutare/redenumire fisier de date asignat unui tablespace(tablespace offline, fisier destinatie existent):
alter tablespace ubd_data1 offline;
alter tablespace ubd_data1 rename datafile 'd:\ubd_data1.dbf' to 'd:\ubd_data33.dbf';
-- Obs. - Fisierul destinatie trebuie sa existe fizic, altfel se genereaza o eroare:

select tablespace_name,file_name,status from dba_data_files;


-- OBS: Baza de date trebuie sa fie in starea MOUNT/OPEN;
-- 18) Mutare/redenumire fisier de date asignat unui database:
alter database rename file 'd:\ubd_data33.dbf' to 'd:\ubd_data44.dbf';

-- 19)Crearea unui tablespace de tip undo:
create undo tablespace ubd_undo1 datafile 'd:\ubd_undo1.dbf' size 10M;


-- 20) Stergerea din dictionar a unui fisier de date asignat unui tablespace(trebuie sa nu fie singurul asignat):
alter tablespace ubd_data1 drop datafile 'd:\ubd_data44.dbf';



-- 21) Stergerea din dictionar a unui fisier temporar asignat unui tablespace(trebuie sa nu fie singurul asignat):
alter tablespace ubd_temp2 drop tempfile 'd:\ubd_temp1.dbf';

-- 22) Stergerea din dictionar a unui fisier temporar asignat unui database:
alter database tempfile 'd:\ubd_temp1.dbf' drop including datafiles;


-- 23) Stergerea din dictionar a unui tablespace(inclusiv fisierele de date asignate):
drop tablespace ubd_data1 including contents and datafiles;


-- Verificare:
select tablespace_name from dba_tablespaces;
select tablespace_name,file_name,status from dba_data_files;
select tablespace_name,file_name,status from dba_temp_files;

-- exercitii
-- 1) care sunt tablespace-urile asignate userului curent
select username, default_tablespace, temporary_tablespace from dba_users where username = 'ABD1';

-- 2) sa se creeze un tablesace temporar UBD_TEMP, Sa se mai adauge un nou fisier de date cu dim. de 2M
-- la acest tablespace si apoi sa se verifice in dictionar daca a fost asignat
create temporary tablespace ubd_temp4 tempfile 'd:\ubd_temp4.dbf' size 10M extent management local uniform size 2M;
alter tablespace ubd_temp4 add tempfile 'd:\ubd_data12.dbf' size 10M;

select * from v$tempfile;

-- 3) sa se arate din dictionar numele tablespace-urilor permanente si temporare setate ca DEFAULT
-- in baza de date curenta
SELECT PROPERTY_VALUE
FROM DATABASE_PROPERTIES
WHERE PROPERTY_NAME = 'DEFAULT_PERMANENT_TABLESPACE' OR PROPERTY_NAME = 'DEFAULT_TEMP_TABLESPACE';