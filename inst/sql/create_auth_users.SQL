CREATE TABLE auth_users (
userid integer(11) NOT NULL AUTO_INCREMENT,
username char(100),
passwordhash char(101),
PRIMARY KEY (userid)
);
