-- template spool


spool c:\users\adrian\documents\ubd\spool_ubd\spool_ubd_lab2_12oct2021
set lines 200
set pages 100
select to_char(sysdate, ’dd-mm-yyyy hh:mi:ss’) from dual;

--- incepe sesiune
insert into login_lab_ubd values( 'Filimon Adrian', '342C2', 'Lab2', user, sysdate, null, null);


-- sfarsit de laborator

update login_lab_ubd set data_sf= sysdate where laborator='Lab2';
update login_lab_ubd set durata= round((data_sf-data_in)*24*60) where laborator='Lab2';
commit;
select instance_number,instance_name, to_char(startup_time, 'dd-mm-yyyy hh:mi:ss'), host_name from v$instance;
select nume_stud, grupa, laborator, to_char(data_in, 'dd-mm-yyyy hh:mi:ss') data_inceput,
to_char(data_sf, 'dd-mm-yyyy hh:mi:ss') data_sfarsit, durata minute_lucrate from login_lab_ubd;

spool off;