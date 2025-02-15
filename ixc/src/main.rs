#![allow(dead_code)]
#![allow(unused_imports)]
//
#![allow(unused_variables)]
#![allow(unused_mut)]
#![allow(non_snake_case)]
//
#![allow(clippy::iter_nth_zero)]
#![allow(clippy::let_and_return)]

use anyhow::ensure;
use anyhow::Result;

mod frontend;

fn header() {
	println!("* ix *");
}

fn main() -> Result<()> {
	use crate::frontend::parser::parse;
	header();

	let code = std::fs::read_to_string("src/main.ix")?;
	parse::parse_entire_code(&code)?;

	Ok(())
}
