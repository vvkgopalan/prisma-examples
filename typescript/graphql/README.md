# GraphQL Server Example

This example shows how to implement a **GraphQL server with TypeScript** based on [Prisma Client](https://github.com/prisma/prisma2/blob/master/docs/prisma-client-js/api.md), [graphql-yoga](https://github.com/prisma/graphql-yoga) and [Nexus Schema](https://nxs.li/components/standalone/schema). It is based on a Yugabyte database using the YSQL (Postgres wire-compatible) API.

## Prerequisites 

### 1. Get started with Yugabyte and get a cluster up and running!

If you are unfamiliar with Yugabyte and creating a simple cluster, please proceed to this handy [Quick Start](https://docs.yugabyte.com/latest/quick-start/) page to learn more.

The alternative to creating a local cluster is to create a cluster using [Yugabyte Cloud](https://www.yugabyte.com/cloud/) - Yugabyte's fully managed service. You can register for the free cloud tier which includes 5GB of storage that will be replicated across 3 nodes. In order to create a cluster proceed through the following steps:

After registering for the service and logging in, create a Free Tier cluster ![here](https://github.com/vvkgopalan/prisma-examples/blob/master/images/yb_cloud1.png?raw=true)
Then select deployment options from the Free Tier available options ![here](https://github.com/vvkgopalan/prisma-examples/blob/master/images/yb_cloud2.png?raw=true)
And finally view your newly created cluster on this screen ![here](https://github.com/vvkgopalan/prisma-examples/blob/master/images/yb_cloud3.png?raw=true)

### 2. Load some sample data into your new Yugabyte database.

Once your cluster is up and running, we will now load some dummy data by doing the following. First, you will need to navigate to `~/code/yugabyte-db` or wherever you have cloned the `yugabyte-db` repository and connect to your Yugabyte database. If you are using a local cluster, connect to the `yugabyte` database by running `./bin/ysqlsh`. If you are using the Free Cloud Tier, navigate to your cluster and view the connection information by clicking `Connect`. Copy that command and run it locally.

Now once you have connected to the default `yugabyte` database in your cluster by running the above command, load your data via `\i ~/code/prisma-examples/typescript/graphql/prisma/dbcommands.sql`. 

### 3. Add connection information to Prisma environment file. 

Navigate to `~/code/prisma-examples/typescript/graphql/prisma` and modify the `.env` file. To connect your database, you need to set the URL field of the datasource block in your Prisma schema to your database connection URL. In this case, the url is set via an environment variable which is defined in `.env` of the form:
```
DATABASE_URL="postgresql://user:password@host:port/db?schema=name"
```
You will need to change it to the following (if running locally):
```
DATABASE_URL="postgresql://yugabyte@127.0.0.1:5433/yugabyte"
```
If you specified a host and port during cluster creation, you can replace `localhost:5433` with that by fetching it from running `~/code/yugabyte-db/bin/yb-ctl status`.

The parameters for this connection string when using the Free Cloud Tier can be found by navigating to the connection info as you did previously and replacing `user, password, host, and port` accordingly. Replace `db` with `yugabyte` and leave schema empty (default to the public schema). 

## How to use Prisma

### 1. Download example & install dependencies

Clone this repository:

```
git clone git@github.com:prisma/prisma-examples.git --depth=1
```

Install npm dependencies:

```
cd prisma-examples/typescript/graphql
npm install
```

Note that this also generates Prisma Client JS into `node_modules/@prisma/client` via a `postinstall` hook of the `@prisma/client` package from your `package.json`.

### 2. Start the GraphQL server

Launch your GraphQL server with this command:

```
npm run dev
```

Navigate to [http://localhost:4000](http://localhost:4000) in your browser to explore the API of your GraphQL server in a [GraphQL Playground](https://github.com/prisma/graphql-playground).

## Using the GraphQL API

The schema that specifies the API operations of your GraphQL server is defined in [`./schema.graphql`](./schema.graphql). Below are a number of operations that you can send to the API using the GraphQL Playground.

Feel free to adjust any operation by adding or removing fields. The GraphQL Playground helps you with its auto-completion and query validation features.

### Retrieve all published posts and their authors

```graphql
query {
  feed {
    id
    title
    content
    published
    author {
      id
      name
      email
    }
  }
}
```

<Details><Summary><strong>See more API operations</strong></Summary>

### Create a new user

```graphql
mutation {
  signupUser(
    data: {
      name: "Sarah"
      email: "sarah@prisma.io"
    }
  ) {
    id
  }
}
```

### Create a new draft

```graphql
mutation {
  createDraft(
    title: "Join the Prisma Slack"
    content: "https://slack.prisma.io"
    authorEmail: "alice@prisma.io"
  ) {
    id
    published
  }
}
```

### Publish an existing draft

```graphql
mutation {
  publish(id: __POST_ID__) {
    id
    published
  }
}
```

> **Note**: You need to replace the `__POST_ID__`-placeholder with an actual `id` from a `Post` item. You can find one e.g. using the `filterPosts`-query.

### Search for posts with a specific title or content

```graphql
{
  filterPosts(searchString: "graphql") {
    id
    title
    content
    published
    author {
      id
      name
      email
    }
  }
}
```

### Retrieve a single post

```graphql
{
  post(where: { id: __POST_ID__ }) {
    id
    title
    content
    published
    author {
      id
      name
      email
    }
  }
}
```

> **Note**: You need to replace the `__POST_ID__`-placeholder with an actual `id` from a `Post` item. You can find one e.g. using the `filterPosts`-query.

### Delete a post

```graphql
mutation {
  deleteOnePost(where: {id: __POST_ID__})
  {
    id
  }
}
```

> **Note**: You need to replace the `__POST_ID__`-placeholder with an actual `id` from a `Post` item. You can find one e.g. using the `filterPosts`-query.

</Details>


## Evolving the app

Evolving the application typically requires four subsequent steps:

1. Migrating the database schema using SQL
1. Updating your Prisma schema by introspecting the database with `prisma introspect`
1. Generating Prisma Client to match the new database schema with `prisma generate`
1. Using the updated Prisma Client in your application code

For the following example scenario, assume you want to add a "profile" feature to the app where users can create a profile and write a short bio about themselves.

### 1. Change your database schema using SQL

The first step would be to add a new table, e.g. called `Profile`, to the database. Navigate back to `~/code/yugabyte-db

```./bin/ysqlsh
CREATE TABLE "public"."Profile" (
  id SERIAL PRIMARY KEY NOT NULL,
  bio TEXT,
  "userId" INTEGER UNIQUE NOT NULL,
  FOREIGN KEY ("userId") REFERENCES "public"."User"(id)
);
```

Note that we're adding a unique constraint to the foreign key on `user`, this means we're expressing a 1:1 relationship between `User` and `Profile`, i.e.: "one user has one profile".

While your database now is already aware of the new table, you're not yet able to perform any operations against it using Prisma Client. The next two steps will update the Prisma Client API to include operations against the new `Profile` table.

### 2. Introspect your database

The Prisma schema is the foundation for the generated Prisma Client API. Therefore, you first need to make sure the new `Profile` table is represented in it as well. The easiest way to do so is by introspecting your database:

```
npx prisma introspect
```

> **Note**: You're using [npx](https://github.com/npm/npx) to run Prisma 2 CLI that's listed as a development dependency in [`package.json`](./package.json). Alternatively, you can install the CLI globally using `npm install -g @prisma/cli`. When using Yarn, you can run: `yarn prisma dev`.

The `introspect` command updates your `schema.prisma` file. It now includes the `Profile` model and its 1:1 relation to `User`:

```prisma
model Post {
  authorId  Int
  content   String?
  createdAt DateTime @default(now())
  id        Int      @default(autoincrement()) @id
  published Boolean  @default(false)
  title     String
  User      User     @relation(fields: [authorId], references: [id])
}

model Profile {
  bio    String?
  id     Int     @default(autoincrement()) @id
  userId Int     @unique
  User   User    @relation(fields: [userId], references: [id])
}

model User {
  email   String   @unique
  id      Int      @default(autoincrement()) @id
  name    String?
  Post    Post[]
  Profile Profile?
}
```

Which will need to be changed to the following:
```prisma
model Post {
  authorId  Int
  content   String?
  createdAt DateTime @default(now())
  id        Int      @default(autoincrement()) @id
  published Boolean  @default(false)
  title     String
  author    User     @relation(fields: [authorId], references: [id])
}

model Profile {
  bio    String?
  id     Int     @default(autoincrement()) @id
  userId Int     @unique
  user   User    @relation(fields: [userId], references: [id])
}

model User {
  email   String   @unique
  id      Int      @default(autoincrement()) @id
  name    String?
  posts   Post[]
  profile Profile?
}
```

### 3. Generate Prisma Client

With the updated Prisma schema, you can now also update the Prisma Client API with the following command:

```
npx prisma generate
```

This command updated the Prisma Client API in `node_modules/@prisma/client`.

### 4. Use the updated Prisma Client in your application code

#### Expose `Profile` operations via `nexus-prisma`

With the `nexus-prisma` package, you can expose the new `Profile` model in the API like so:

```diff
// ... as before

const User = objectType({
  name: 'User',
  definition(t) {
    t.model.id()
    t.model.name()
    t.model.email()
    t.model.posts({
      pagination: false,
    })
+   t.model.profile()
  },
})

// ... as before

+const Profile = objectType({
+  name: 'Profile',
+  definition(t) {
+    t.model.id()
+    t.model.bio()
+    t.model.user()
+  },
+})

// ... as before

export const schema = makeSchema({
+  types: [Query, Mutation, Post, User, Profile],
  // ... as before
}
```

## Next steps

- Read the holistic, step-by-step [Prisma Framework tutorial](https://github.com/prisma/prisma2/blob/master/docs/tutorial.md)
- Check out the [Prisma Framework docs](https://github.com/prisma/prisma2) (e.g. for [data modeling](https://github.com/prisma/prisma2/blob/master/docs/data-modeling.md), [relations](https://github.com/prisma/prisma2/blob/master/docs/relations.md) or the [Prisma Client API](https://github.com/prisma/prisma2/tree/master/docs/prisma-client-js/api.md))
- Share your feedback in the [`prisma2-preview`](https://prisma.slack.com/messages/CKQTGR6T0/) channel on the [Prisma Slack](https://slack.prisma.io/)
- Create issues and ask questions on [GitHub](https://github.com/prisma/prisma2/)
- Track Prisma 2's progress on [`isprisma2ready.com`](https://isprisma2ready.com)

