CREATE TABLE auth_users (
userid integer(11) not null,
username char(12),
passwordhash char(101),
PRIMARY KEY (userid)
);
