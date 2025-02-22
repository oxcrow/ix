use anyhow::ensure;
use anyhow::Result;

use pest::Parser;
use pest_derive::Parser;
//
use pest::iterators::Pair;
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
pub fn parse_tree<'arena>(mut arena: Arena::Allocator, tree: Pairs<'arena, Rule>) -> Result<()> {
	let mut ast = Arena::Vec::<Nodes>::new_in(&arena);
	let mut identifiers = Arena::Vec::<&'arena str>::new_in(&arena);
	let mut documentations = Arena::Vec::<&'arena str>::new_in(&arena);
	let mut comments = Arena::Vec::<&'arena str>::new_in(&arena);

	let mut queue = Arena::Vec::<Pair<'arena, Rule>>::new_in(&arena);

	for pair in tree {
		let rule = pair.as_rule();
		let node = rule_to_node(rule);
		for inner in pair.into_inner() {
			queue.push(inner);
		}
		ast.push(node);
	}

	parse_tree_recursive(&arena, &mut queue, &mut ast, &mut identifiers, &mut comments, &mut documentations);

	dbg!(&ast);
	Ok(())
}

fn parse_tree_recursive<'arena>(
	arena: &'arena Arena::Allocator,
	queue: &mut Arena::Vec<Pair<'arena, Rule>>,
	ast: &mut Arena::Vec<Nodes>,
	identifiers: &mut Arena::Vec<&'arena str>,
	comments: &mut Arena::Vec<&'arena str>,
	documentations: &mut Arena::Vec<&'arena str>,
) {
	if queue.is_empty() {
		return;
	}

	let mut queue_inner = Arena::Vec::<Pair<'arena, Rule>>::new_in(&arena);

	for pair in queue.iter() {
		let rule = pair.as_rule();
		let node = rule_to_node(rule);
		for inner in pair.clone().into_inner() {
			queue_inner.push(inner);
		}
		dbg!(rule);
		ast.push(node);
	}

	queue.clear();
	for inner in queue_inner {
		queue.push(inner);
	}

	parse_tree_recursive(arena, queue, ast, identifiers, documentations, comments);
}

fn rule_to_node(rule: Rule) -> Nodes {
	match rule {
		| Rule::doc => Nodes::Documentation,
		| Rule::comment => Nodes::Comment,
		| Rule::function => Nodes::Function,
		| Rule::r#static => Nodes::Visible,
		| Rule::id => Nodes::Identifier,
		| _ => Nodes::Unknown,
	}
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
