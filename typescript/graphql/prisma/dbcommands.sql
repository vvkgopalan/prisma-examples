BEGIN TRANSACTION;
CREATE TABLE "public"."User" (
  id SERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL
);
INSERT INTO "User" VALUES(1, 'GraphQL', 'graphql@yugabyte.com');
INSERT INTO "User" VALUES(2, 'Prisma', 'prisma@yugabyte.com');
CREATE TABLE "public"."Post" (
  id SERIAL PRIMARY KEY NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  published BOOLEAN NOT NULL DEFAULT false,
  "authorId" INTEGER NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY ("authorId") REFERENCES "public"."User"(id)
);
INSERT INTO "Post" VALUES(1, 'Learn how to use Yugabyte with Prisma.', 'https://docs.yugabyte.com/latest/develop/graphql/prisma/', False, 2);
INSERT INTO "Post" VALUES(2, 'Learn more about Yugabyte and GraphQL.', 'https://docs.yugabyte.com/latest/develop/graphql/', True, 1);
COMMIT;
