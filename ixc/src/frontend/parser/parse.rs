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

use super::ast;

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
pub fn parse_tree<'a>(mut arena: Arena::Allocator, tree: Pairs<'a, Rule>) -> Result<()> {
    let mut ast = Arena::Vec::<Nodes>::new_in(&arena);
    let mut identifiers = Arena::Vec::<&'a str>::new_in(&arena);
    let mut documentations = Arena::Vec::<&'a str>::new_in(&arena);
    let mut comments = Arena::Vec::<&'a str>::new_in(&arena);

    let mut queue = Arena::Vec::<Pair<'a, Rule>>::new_in(&arena);

    for pair in tree {
        let rule = pair.as_rule();
        ensure!(rule == Rule::file);
        for inner in pair.into_inner() {
            queue.push(inner);
        }
    }

    parse_tree_recursive(&arena, &mut queue, &mut ast, &mut identifiers, &mut comments, &mut documentations);

    dbg!(&ast);
    dbg!(&identifiers);
    Ok(())
}

fn parse_tree_recursive<'a>(
    arena: &'a Arena::Allocator,
    queue: &mut Arena::Vec<Pair<'a, Rule>>,
    ast: &mut Arena::Vec<Nodes>,
    identifiers: &mut Arena::Vec<&'a str>,
    comments: &mut Arena::Vec<&'a str>,
    documentations: &mut Arena::Vec<&'a str>,
) {
    if queue.is_empty() {
        return;
    }

    let mut queue_inner = Arena::Vec::<Pair<'a, Rule>>::new_in(&arena);

    for pair in queue.iter() {
        let rule = pair.as_rule();
        let node = convert_rule_to_node(rule);
        let string = pair.as_str();
        for inner in pair.clone().into_inner() {
            queue_inner.push(inner);
        }

        match node {
            | Nodes::Module => ast.push(Nodes::StartModule),
            | Nodes::Function => {
                ast.push(Nodes::StartFunction);
                parse_tree_recursive(arena, &mut queue_inner, ast, identifiers, comments, documentations);
                ast.push(Nodes::EndFunction);
            }
            | Nodes::Struct => {
                ast.push(Nodes::StartStruct);
                parse_tree_recursive(arena, &mut queue_inner, ast, identifiers, comments, documentations);
                ast.push(Nodes::EndStruct);
            }
            | Nodes::Expressions => {
                ast.push(Nodes::StartExpression);
                parse_tree_recursive(arena, &mut queue_inner, ast, identifiers, comments, documentations);
                ast.push(Nodes::EndExpression);
            }
            | _ => {}
        }

        match node {
            | Nodes::Documentation => {
                ast.push(node);
                documentations.push(string);
            }
            | Nodes::Comment => {
                ast.push(node);
                comments.push(string);
            }
            | Nodes::Identifier => {
                ast.push(node);
                identifiers.push(string);
            }
            | Nodes::Assignment => {
                ast.push(node);
            }
            | Nodes::ConstantAssignment => {
                ast.push(node);
            }
            | Nodes::VariableAssignment => {
                ast.push(node);
            }
            | Nodes::Usize => {
                ast.push(node);
            }
            | _ => {}
        }

        if node.is_module() || node.is_function() || node.is_struct() {
            dbg!(&node);
            dbg!(pair);
        }
    }

    queue.clear();
    for inner in queue_inner {
        queue.push(inner);
    }

    parse_tree_recursive(arena, queue, ast, identifiers, documentations, comments);
}

fn convert_rule_to_node(rule: Rule) -> Nodes {
    match rule {
        | Rule::doc => Nodes::Documentation,
        | Rule::comment => Nodes::Comment,
        | Rule::function => Nodes::Function,
        | Rule::r#return => Nodes::Return,
        | Rule::expressions => Nodes::Expressions,
        | Rule::expression => Nodes::Expression,
        | Rule::assignment => Nodes::Assignment,
        | Rule::constant_assignment => Nodes::ConstantAssignment,
        | Rule::variable_assignment => Nodes::VariableAssignment,
        | Rule::visible => Nodes::Visible,
        | Rule::hidden => Nodes::Hidden,
        | Rule::id | Rule::idx => Nodes::Identifier,
        | Rule::usize => Nodes::Usize,
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
