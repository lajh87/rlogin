CREATE TABLE auth_tokens (
id INTEGER PRIMARY KEY,
selector char(12),
hashedValidator char(64),
userid integer(11),
expires datetime
);
