-- sudo systemctl stop tomcat.service
-- sudo su - postgres
-- dropdb poipiku
-- createdb poipiku
-- gunzip -c poipiku.sql-20220312.gz | psql -d poipiku
update tbloauth set fldsecrettoken='', fldaccesstoken='';
update users_0000 set password='will3in', email=user_id || '@will3in';
delete from temp_emails_0000;
delete from creditcards;
delete from order_details;
delete from orders;
-- sudo systemctl start tomcat.service
