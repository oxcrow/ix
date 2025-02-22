use anyhow::ensure;
use anyhow::Result;

use pest::Parser;
use pest_derive::Parser;
//
use pest::iterators::Pairs;

use crate::core::arena::Arena;
//
use crate::frontend::parser::ast::Ast;
use crate::frontend::parser::ast::Nodes;

// Ix parser created from pest grammar
#[derive(Parser)]
#[grammar = "src/frontend/parser/ix.pest"]
struct IxParser;

/// Parse the source cdode and create a parse pair tree
pub fn parse_string(source: &str) -> Result<Pairs<'_, Rule>> {
	let tree = IxParser::parse(Rule::file, source)?;
	Ok(tree)
}

/// Parse the parse tree and create an Abstract Syntax Tree (AST)
pub fn parse_tree<'arena>(mut arena: Arena::Allocator, tree: Pairs<'_, Rule>) -> Result<()> {
	let mut ast = Arena::Vec::<Nodes>::new_in(&arena);
	let mut identifiers = Arena::Vec::<&str>::new_in(&arena);
	let mut documentations = Arena::Vec::<&str>::new_in(&arena);
	let mut comments = Arena::Vec::<&str>::new_in(&arena);

	for pair in tree {
		let rule = pair.as_rule();
		dbg!(rule);
	}

	Ok(())
}

#[cfg(test)]
mod utest {
	use super::*;

	#[test]
	fn test_parse_string() -> Result<()> {
		parse_string("fn one() usize { let x = 1; x }")?;
		parse_string("struct Node { vis x,y,z float }")?;
		parse_string("struct Node { x,y,z float }")?;
		Ok(())
	}

	#[test]
	fn test_parse_tree() -> Result<()> {
		let arena = Arena::Allocator::new();
		let tree = parse_string("fn main() {}")?;
		let ast = parse_tree(arena, tree)?;
		Ok(())
	}
}
