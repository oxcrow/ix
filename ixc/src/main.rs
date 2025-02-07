#![allow(dead_code)]
#![allow(unused_imports)]
//
#![allow(unused_variables)]
#![allow(unused_mut)]
#![allow(non_snake_case)]

use anyhow::ensure;
use anyhow::Result;

mod frontend;

fn header() {
	println!("* ix *");
}

fn main() -> Result<()> {
	use crate::frontend::lexer::lex;
	header();

	let code = std::fs::read_to_string("src/main.ix")?;
	let mut code = &code[0..];

	while !code.is_empty() {
		let (tokens, xcode) = lex::lex_line(&code)?;
		code = xcode;
	}

	Ok(())
}
