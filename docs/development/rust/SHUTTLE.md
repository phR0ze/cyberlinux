# Shuttle
[Shuttle](https://www.shuttle.rs/) is a Rust-native cloud development platform that provides the 
ability to dynamically configure infrastructure based on code annotations. Their automation removes 
the need to directly setup any backend services.

## Getting Started
You can get started with their ***Hobby*** plan for free to test it out:

| Features           | Limits      |
| ------------------ | ----------- |
| Team size          |      1      |
| Deployments        |  unlimited  |
| Number of projects |      5      |
| Requests           | 150k/month  |
| Workers            |      1      |
| Database storage   |    500MB    |

***References***
* [Quick Start - Shuttle docs](https://docs.shuttle.rs/introduction/quick-start)

1. Create Shuttle account with Github authorization
   1. Navigate to https://www.shuttle.rs/login
   2. Click through the authorization for `shuttle-hq`
   3. From the dashboard page copy out step 3 which has your account API key for login later
2. Create a Shuttle compatible project
   1. Create new cargo project, note project names need to be globally unique:
      ```bash
      $ cargo new shuttle1
      $ cd shuttle1
      ```
    2. Add axum dependencies
      ```bash
      $ cargo add axum tokio --features tokio/full
      ```
    3. Add shuttle dependencies
      ```bash
      $ cargo add shuttle-axum shuttle-runtime
      ```
    4. Update your `src/main.rs` to the following:
      ```rust
      use axum::{response::IntoResponse, routing::get, Router};
      
      #[shuttle_runtime::main]
      async fn shuttle() -> shuttle_axum::ShuttleAxum {
          let app = Router::new().route("/", get(hello_world));
          Ok(app.into())
      }
      
      async fn hello_world() -> impl IntoResponse {
          "Hello world"
      }
      ```
3. Configure Shuttle Cargo plugin
   1. Install Shuttle Cargo plugin
      ```bash
      $ cargo install cargo-shuttle
      ```
   2. Log in via Shuttle Cargo plugin
      ```bash
      $ cargo shuttle login --api-key <API-key-from-dashboard-page>
      ```
4. Configure new project for Shuttle
   1. Make the Shuttle Cargo plugin aware of the project
      ```bash
      $ cargo shuttle project start
      ```
      Note: if you get a project name collision, change it in your `Cargo.toml`
   2. Run project locally:
      ```bash
      $ cargo shuttle run
      ```
      Note: this seems to take a long time pulling crates.io and utimately fails with a bug to find an open port
   3. Deploy your project to public shuttle
      ```bash
      $ cargo shuttle deploy --allow-dirty
      ```
      Note: this will build, run tests then deploy your project on Shuttle's infra. It does cache for 
      faster rebuilds which is nice.
   4. Navigate to your live project at https://<project-name>.shuttleapp.rs  
      e.g.https://shuttle1-axum-test.shuttleapp.rs
   5. Find the projects status and endpoint with
      ```bash
      $ cargo shuttle status
      ```

### Idle Projects
Shuttle will put projects to sleep after 30 min very low activity:
* Axum projects need ~2 requests per min over idle-time period to be considered active
* Discord bot needs about 6 calls per minute over idle-time period to be considered active
* User interaction e.g. `cargo shuttle status` and others except `cargo shuttle project <cmd>` will 
also be considered active

Waking projects will take about 1 sec to be functional again

Configure timeout to be longer duration. Duration of `0` will make project never sleep:
```bash
$ cargo shuttle project start --idle-minutes 40
```

### Local test run
[Shuttle local test run](https://docs.shuttle.rs/introduction/local-run) can be used to run your 
project locally before deploying to the shuttle public environment.

Run the project locally with Shuttle Cargo plugin, optionally you can change the port else it 
defaults to `0.0.0.0:8000`. `--exteranl` is required to expose your app to your local network.
```bash
$ cargo shuttle run --external --port 3000
```

**Local runs with databases**  
If your project relies on database resources, it will default to startgin a docker container for that 
database. If you'd like to opt out of this behavior and rather supply your own databse URI, simply 
pass it in as an argument to your resource.

```rust
#[shuttle_runtime::main]
async fn tide(#[shuttle_aws_rds::Postgres(
        local_uri = "postgres://postgres:{secrets.PASSWORD}@localhost:16695/postgres"
    )] pool: PgPool) -> ShuttleTide<MyState> { ... }
```

### View deployment history
From the directory of your project run:

```bash
$ cargo shuttle deployment list
```

### Telemetry
[Tracing is added by default](https://docs.shuttle.rs/introduction/telemetry) so all you need to do 
is import the macros and use them:
```rust
use tracing::info;

#[shuttle_runtime::main]
async fn axum(#[shuttle_shared_db::Postgres] pool: PgPool) -> ShuttleAxum { 
    info!("Running database migration");
    pool.execute(include_str!("../schema.sql"))
        .await
        .map_err(CustomError::new)?;
}
```

***View deployment logs***
From the directory of your project run:
```bash
$ cargo shuttle logs
```

Follow logs with the `--follow`
```bash
$ cargo shuttle logs --follow
```

Alternately you can list logs for a particular deployment by id found with `deployment list`:
```bash
$ cargo shuttle logs <id>
```

## Headers available in Shuttle
You can get all headers available from the request with:
```rust
async fn client_ip_address(headers: HeaderMap) -> impl IntoResponse {
    format!("{headers:?}")
}
```

Results for curl:
```json
{
  "host": "shuttle1-axum-test.shuttleapp.rs",
  "user-agent": "curl/8.0.1",
  "accept": "*/*",
  "x-shuttle-project": "shuttle1-axum-test",
  "traceparent": "00-0350f4d74fb3a6583058a8da75865447-de1fcb5b39509976-01",
  "tracestate": "",
  "x-forwarded-for": "127.0.0.1"
}
```

Results for firefox:
```json
{
  "host": "shuttle1-axum-test.shuttleapp.rs",
  "user-agent": "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/109.0",
  "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
  "accept-language": "en-US,en;q=0.5",
  "accept-encoding": "gzip, deflate, br",
  "dnt": "1",
  "tracestate": "",
  "upgrade-insecure-requests": "1",
  "sec-fetch-dest": "document",
  "sec-fetch-mode": "navigate",
  "sec-fetch-site": "none",
  "sec-fetch-user": "?1",
  "sec-gpc": "1",
  "x-shuttle-project": "shuttle1-axum-test",
  "traceparent": "00-6227bed124a73302d423f04795ca7b8e-82fd3f90178128b3-01",
  "x-forwarded-for": "127.0.0.1"
}
```
