use ethers::utils::Ganache;
use eyre::Result;


// This function spawns a local Ganache instance and prints the HTTP endpoint
// Code from:  https://coinsbench.com/ethereum-with-rust-tutorial-part-1-create-simple-transactions-with-rust-26d365a7ea93
#[tokio::main]
async fn main() -> Result<()> {
    // Spawn a aanache instance
    let ganache = Ganache::new().spawn();
    println!("HTTP Endpoint: {}", ganache.endpoint());
    Ok(())
}

