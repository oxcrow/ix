use anyhow::ensure;
use anyhow::Result;

use pest::Parser;
use pest_derive::Parser;
//
use pest::iterators::Pairs;

// Ix parser created from pest grammar
#[derive(Parser)]
#[grammar = "src/frontend/parser/ix.pest"]
struct IxParser;

/// Parse the source cdode and create a parse pair tree
pub fn parse_string(source: &str) -> Result<Pairs<'_, Rule>> {
	let parse_tree = IxParser::parse(Rule::file, source)?;
	Ok(parse_tree)
}

/// Parse the parse tree and create an Abstract Syntax Tree (AST)
pub fn parse_tree(tree: &Pairs<'_, Rule>) -> Result<()> {
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
