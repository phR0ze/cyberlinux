Databases
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust Databases
<br><br>

### Quick links
* [.. up dir](..)
* [SeaORM](#seaorm)
  * [SeaORM Overview](#seaorm-overview)
  * [Database and Async Runtime](#database-and-async-runtime)
  * [Migrations with SeaORM](#migrations-with-seaorm)

# SeaORM
An Object Relational Mapper (ORM) is a programming library to help you interact with a relational 
database from an Object-Oriented Programming (OOP) language.

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

**Supported Database Drivers:**
* `sqlx-mysql`
* `sqlx-postgres`
* `sqlx-sqlite`

**Supported Async Runtimes:**
* `runtime-actix-native-tls`
* `runtime-async-std-native-tls`
* `runtime-tokio-native-tls`
* `runtime-actix-rustls`
* `runtime-async-std-rustls`
* `runtime-tokio-rustls`

**Async runtimes are associated with a specific web framework**
| Async Runtime | Web Framework |
| ------------- | ------------- |
| actix         | Actix         |
| async-std     | Tide          |
| tokio         | Axum, Rocket  |

Thus final dependency string would be
```toml
[dependencies]
sea-orm = { version = "^0", features = [ "sqlx-sqlite", "runtime-tokio-rustls", "macros" ] }
```

## Migrations with SeaORM
* [SeaORM docs on Migrations](https://www.sea-ql.org/SeaORM/docs/migration/setting-up-migration/)

<!-- 
vim: ts=2:sw=2:sts=2
-->
