#![allow(dead_code)]
#![allow(unused_imports)]
//
#![allow(unused_variables)]
#![allow(unused_mut)]
#![allow(non_snake_case)]

use anyhow::ensure;
use anyhow::Result;

fn header() {
	println!("* ix *");
}

fn main() -> Result<()> {
	header();
	Ok(())
}
