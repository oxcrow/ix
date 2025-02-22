#![allow(dead_code)]
#![allow(unused_imports)]
//
#![allow(unused_variables)]
#![allow(unused_mut)]
#![allow(non_snake_case)]
//
#![allow(clippy::iter_nth_zero)]
#![allow(clippy::let_and_return)]

use core::arena::Arena;

use anyhow::ensure;
use anyhow::Result;

mod core;
mod frontend;

fn header() {
	println!("* ix *");
}

fn dev() -> Result<()> {
	Ok(())
}

fn main() -> Result<()> {
	use crate::frontend::parser::parse;
	header();

	// Read code from file and compile it
	// Note: We should try to compile incrementally.
	let arena = Arena::Allocator::with_capacity(1e+7 as usize);
	let code = std::fs::read_to_string("src/main.ix")?;
	let tree = parse::parse_string(&code)?;
	let ast = parse::parse_tree(arena, tree)?;

	dev()?;
	Ok(())
}
