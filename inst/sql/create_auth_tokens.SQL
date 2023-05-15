CREATE TABLE auth_tokens (
id integer(11) not null,
selector char(12),
hashedValidator char(64),
userid integer(11) not null,
expires datetime,
PRIMARY KEY (id)
);
