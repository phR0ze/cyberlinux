Databases
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust Databases
<br><br>

### Quick links
* [.. up dir](..)
* [SeaORM](#seaorm)
  * [SeaORM Overview](#seaorm-overview)
    * [SeaORM Concepts](#seaorm-concepts)
  * [Database and Async Runtime](#database-and-async-runtime)
    * [Supported Database Drivers](supported-database-drivers)
    * [Supported Async Runtimes](supported-async-runtimes)
    * [Supported Web Frameworks](supported-web-frameworks)
    * [Final dependency choices](final-dependency-choices)
  * [Axum Web Framework](#axum-web-framework)
  * [Migrations with SeaORM](#migrations-with-seaorm)
* [Database](#database)
  * [Index](#index)

# SeaORM
An Object Relational Mapper (ORM) is a programming library to help you interact with a relational 
database from an Object-Oriented Programming (OOP) language.

**References**
* [SeaORM docs - Getting started](https://www.sea-ql.org/sea-orm-tutorial/ch01-00-build-backend-getting-started.html)

## SeaORM Overview
Tables and columns in a database are mapped to objects and attributes, while additional methods allow 
you to load and store data from and to the database.

SeaORM is built from the ground up with async support in mind. The first thing to learn is the 
`Future` trait. It's a placeholder for a function that will compute and return some value in the 
future. It's lazy, meaning `.await` must be called for any actual work to be done. `Future` allows us 
to achieve concurrency with little programming effor, e.g. `future::join_all` allows us to execute 
multiple queries in parallel.

Second, `async` in Rust is multi-threaded programming with syntactic sugar. A `Future` may move 
between threads, so any variables used in async bodies must be able to travel between threads i.e. 
they must be `Send`.

### SeaORM Concepts
In SeaORM, a database with a collection of tables is called a `Schema`. Each table corresponds to an 
`Entity` in SeaORM which helps you perform `CRUD` (Create, Read, Update, and Delete) operations on 
relevant tables.

The `Entity` trait provides an API for you to inspect its properties (`Column`, `Relation` and 
`PrimaryKey`) at runtime. Each table has multiple columns, which are referred to as `attributes`. 
These attributes and their values are grouped in a Rust struct a `Model`. Models are for read 
operations only. To perform insert, update or delete you need to use the `ActiveModel` which attaches 
meta-data on each attribute to track changes.

There is no global context for SeaORM. Application code is responsible for managing the ownership of 
the `DatabaseConnection`. SeaORM does provide integration examples for web frameworks including 
`Rocket`, `Actix`, `axum` and `poem` to help you get started quickly.

## Database and Async Runtime
You need to choose a database driver and an async runtime to get going
* [SeaORM docs on Database & Async Runtime](https://www.sea-ql.org/SeaORM/docs/install-and-config/database-and-async-runtime/)

### Supported Database Drivers
| Driver                    | Connection string                     |
| ------------------------- | ------------------------------------- |
| `sqlx-mysql`              | `mysql://root:root@localhost:3306`    |
| `sqlx-postgres`           | `postgres://root:root@localhost:5432` |
| `sqlx-sqlite` (in file)   | `sqlite:./sqlite.db?mode=rwc`         |
| `sqlx-sqlite` (in memory) | `sqlite::memory:`                     |

### Supported Async Runtimes
* `runtime-actix-native-tls`
* `runtime-async-std-native-tls`
* `runtime-tokio-native-tls`
* `runtime-actix-rustls`
* `runtime-async-std-rustls`
* `runtime-tokio-rustls`

### Supported Web Frameworks
| Async Runtime | Web Framework |
| ------------- | ------------- |
| actix         | Actix         |
| async-std     | Tide          |
| tokio         | Axum, Rocket  |

### Final dependency choices

Changes to your `Crates.toml` file
```toml
[dependencies]
sea-orm = { version = "^0", features = [ "sqlx-sqlite", "runtime-tokio-rustls", "macros" ] }
```

## Axum Web Framework

* [Axum example guide](https://github.com/SeaQL/sea-orm/tree/master/examples/axum_example)

## Migrations with SeaORM
* [SeaORM docs - Migrations](https://www.sea-ql.org/SeaORM/docs/migration/setting-up-migration/)
* [SeaORM docs - Migration CLI](https://www.sea-ql.org/sea-orm-tutorial/ch01-02-migration-cli.html)

### Integrate migrations via the CLI
1. Install the `sea-orm-cli`:
   ```shell
   $ cargo install sea-orm-cli
   ```
2. Now invoke the cli to create a new migrations package
   ```shell
   $ cd ~/Projects/<project>
   $ sea-orm-cli migrate init
   ```
3. Now edit the `migration/src/m20220101_000001_create_table.rs` file
   1. Add in the changes to make and the rollback instructions
4. Edit the `migration/src/lib.rs` to reflect the appropriate migration files
5. Edit the package `Cargo.toml` and set the SeaORM driver features to match your project
   ```toml
   [dependencies.sea-orm-migration]
   version = "0.11.0"
   features = [
       "sqlx-sqlite",
       "runtime-tokio-rustls",
   ]
   ```
6. Perform all the migrations via `sea-orm-cli` from the root of your project
   ```shell
   $ cd ~/Projects/<project>
   $ DATABASE_URL="sqlite:./sqlite.db" sea-orm-cli migrate refresh
   ```
   * Note that the file must exist first so create it `touch sqlite.db`
7. Use `sqlitebrowser` or other app to view and ensure your structure is accurate

### Integrate migrations programmatically
To get up and running faster I'd recommend using the `sea-orm-cli` option above the first time to 
generate the migration placeholder files then you can just copy those into place with small changes.

1. Add the `sea-orm-migration` dependency to your app along side `sea-orm`:
   ```toml
   [dependencies]
   sea-orm = { version = "0.11.3", features = [ "sqlx-sqlite", "runtime-tokio-rustls", "macros" ] }
   sea-orm-migration = "0.11.3"
   ```
2. Create a new module `migrations`
   1. Create a directory `mkdir src/migrations`
   2. Copy the `migration/src/lib.rs` to `src/migrations/mod.rs`
   3. Copy the `m20220101_000001_create_table.rs` migration file to `src/migrations`
3. Edit your project `main.rs` and include the migrations mod and a function to run it
   ```rust
   mod migrations;
   use sea_orm_migration::prelude::*;

   #[tokio::main]
   async fn main() {
       migrations Migrator::up(db, None).await?;
   }
   ```
4. Generate entity 
   ```
   $ cd ~/Projects/<project>
   $ sea-orm-cli generate entity -u sqlite:./sqlite.db -o src/entities
   ```
5. I modified the model structs to use `chrono::NaiveDateTime` manually.
6. Additionally I modified the model structs to be `serde::{Deserialize, Serialize}`

# Database

## SQLite Foreign Key
Links data in one table to a parent table such that the parent data can't be removed until the child 
data is first removed. Likewise data can't be inserted into the child referring to a parent that 
doesn't exist. It essentially lets the database know about the releationship so it can set up some 
contraints that the database will enforce.

* [SQLite Foreign Key docs](https://www.sqlitetutorial.net/sqlite-foreign-key/)

## SQLite Index
In relational databases an index is an additional data structure that helps improve the performance 
of a query. SQLite uses B-tree for organizing indexes. 

* [SQLite Index docs](https://www.sqlitetutorial.net/sqlite-index/)

<!-- 
vim: ts=2:sw=2:sts=2
-->
