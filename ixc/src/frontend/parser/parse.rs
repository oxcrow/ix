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
