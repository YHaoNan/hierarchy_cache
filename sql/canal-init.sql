-- create canal user and give correct privileges

CREATE USER canal@'%' IDENTIFIED by 'canal';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT, SUPER ON *.* TO 'canal'@'%' IDENTIFIED BY 'canal';
FLUSH PRIVILEGES;
