# Async

Researching Rust's async mechanisms

# Projects

## Tokio
Read a file async using `tokio::fs::read`

```rust
fn main() {
    let task = tokio::fs::read("/proc/cpuinfo").map(|data| {
        // do something with the contents of the file ...
        println!("contains {} bytes", data.len());
        println!("{:?}", String::from_utf8(data));
    }).map_err(|e| {
        // handle errors
        eprintln!("IO error: {:?}", e);
    });
    tokio::run(task);
}
```

