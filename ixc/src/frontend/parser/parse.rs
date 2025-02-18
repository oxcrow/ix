use anyhow::ensure;
use anyhow::Result;

use pest::Parser;
use pest_derive::Parser;

// Ix parser created from pest grammar
#[derive(Parser)]
#[grammar = "src/frontend/parser/ix.pest"]
struct IxParser;

/// Parse the source cdode and create an AST
pub fn parse_entire_code(source: &str) -> Result<()> {
	let mut parse_tree = IxParser::parse(Rule::file, source)?;
	dbg!(&parse_tree);
	Ok(())
}

#[cfg(test)]
mod utest {
	use super::*;

	#[test]
	fn test_parser() -> Result<()> {
		parse_string("fn one() usize { let x = 1; x }")?;
		parse_string("struct Node { vis x,y,z float }")?;
		parse_string("struct Node { x,y,z float }")?;
		Ok(())
	}
}
