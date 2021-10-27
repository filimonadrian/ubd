
-- 1) Informatii despre fisierele de control extrase din view-uri dinamice:
desc v$controlfile
select name, block_size, file_size_blks from v$controlfile;

-- 2) Informatii despre fisierele de control extrase din view-ul pentru parametri:
desc v$parameter
select name, type, value from v$parameter where name='control_files';

-- 3) Informatii despre marimea inregistrarii, numarul total de inregistrari alocate si cele utilizate
-- referitoare la parametrii de control:

desc v$controlfile_record_section
select * from v$controlfile_record_section;

-- 4) Vizualizare fisiere de control:
show PARAMETER CONTROL_FILES

-- 5) Informatii despre fisierele temporare:
desc v$tempfile
select * from v$tempfile;

-- 6) Informatii despre tablespace-uri:
desc v$tablespace
select ts#, name, included_in_database_backup from v$tablespace;

-- 7) Informatii despre baza de date si fisierele de control
desc v$database
select controlfile_type, controlfile_sequence#, controlfile_change#, controlfile_time from v$database;
select * from v$database;


-- aratati din dictionar care sunt fisierele de control asignate la baza de date curenta si data cand au fost create
show PARAMETER CONTROL_FILES
select name, created, controlfile_created from v$database;

-- other solutions
select name, controlfile_type, controlfile_created from v$database;
select name, value from v$parameter where name='control_files';


-- aratati din dictionar care este numarul maxim de fisiere temporare care se pot creea pentru baza de date curenta
select * from v$parameter where name = 'db_files'
select * from v$controlfile_record_section where type='TEMPORARY FILENAME';
