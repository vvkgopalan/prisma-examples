BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "User" ( 
	email TEXT NOT NULL UNIQUE, 
	id INTEGER PRIMARY KEY, 
	name TEXT
);
INSERT INTO "User" VALUES('graphql@yugabyte.com',1,'GraphQL');
INSERT INTO "User" VALUES('prisma@yugabyte.com',2,'Prisma');
CREATE TABLE IF NOT EXISTS "Post" (
	authorId INTEGER,
	content TEXT,
	id INTEGER PRIMARY KEY,
	published BOOLEAN DEFAULT false,
	title TEXT NOT NULL,
	FOREIGN KEY(authorId) REFERENCES "User"(id) ON DELETE SET NULL
);
INSERT INTO "Post" VALUES(2,'https://docs.yugabyte.com/latest/develop/graphql/prisma/',1,False,'Learn how to use Yugabyte with Prisma.');
INSERT INTO "Post" VALUES(1,'https://docs.yugabyte.com/latest/develop/graphql/',2,True,'Learn more about Yugabyte and GraphQL.');
COMMIT;
