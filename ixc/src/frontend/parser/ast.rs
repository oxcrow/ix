use std::convert::identity;

use anyhow::ensure;
use anyhow::Result;

use enum_as_inner::EnumAsInner;

/// Arena interface reconfiguration
///
/// Naming scheme and organization used by bumpallo is sub-optimal.
/// Thus they have been reconfigured to be easier to understand and use.
pub mod Arena {
	pub use bumpalo::Bump as Allocator;

	pub use bumpalo::collections::String;
	pub use bumpalo::collections::Vec;

	pub use bumpalo::vec;
}

/// Abstract syntax tree
pub struct Ast<'arena> {
	state: State,
	pub signature: Signature<'arena>,
	pub context: Context,
	pub reference: Reference,
}

/// Abstract syntax tree state
///
/// Whether we like it or not we need to have some way to represent mutable states.
/// Specifically things that are necessary for keeping records of how the code is composed.
struct State {
	/// A unique identifier generator that we can use for creating unique references to external entities.
	///
	/// We want to use a hashing algorithm that would create perfect unique identities, but that's impossible.
	/// Hashing algorithms have collisions and are imperfect in nature. To prevent collisions we need to use more bits.
	/// However that would significanlty increase our memory requirements for each AST node. Thus we avoid it for now.
	///
	/// As a simple and 100% collision free solution we use an integer as our unique identifier.
	/// For every node this unique identifier state will be incremented and will become the new unique identifier.
	next_unique_identifier: u16,
}

/// Abstract syntax tree signature
///
/// This only contains data regarding the signature of top level nodes such as structs, enums, functions.
/// We store this data separately since this data is required by external modules for name resolution, type checking,
/// ownership checking, and ensuring that we can compile every dependent module in parallel *without* compiling this
/// module completely first.
///
/// That is,
/// If we code `std.io.println("Hello world!")` we do not need to know what happens inside `println`.
/// We are only concerned with the type signature of `println` and as long as the type signature is verified,
/// the code is expected to work correctly, and is not the concern of the module which calls `println`.
/// Thus this type signature is crucial for us and we need an efficient way to store and retrieve it.
/// Thus we store them in a SoA (Structure of Arrays) form.
///
/// SoA form is also selected because it allows us to do fast iterative searches through the AST.
/// As in, when we want to run queries such as, "Find me all structs within this module", we only have to iterate
/// through symbol_types and find the indices of the AST nodes which are structs.
///
/// This is an efficient way to store and search our data. (since hard disks are slow.)
#[derive(Debug)]
pub struct Signature<'arena> {
	/// Identifiers of symbols such as structs, enums, functions, etc.
	pub symbol_identifiers: Arena::Vec<'arena, &'arena str>,

	/// Symbol kinds such as structs, enums, functions, etc.
	pub symbol_kinds: Arena::Vec<'arena, Nodes>,

	/// Sizes of symbols determined at compile time.
	///
	/// The statically determined size of each struct, enum, etc. will be stored in this.
	/// Since a structs and enums may contain too many elements we need u16 to store it.
	/// Since functions, modules, aliases, etc. do not have any meaningful sizes, their size will be stored as zero.
	pub symbol_sizes: Arena::Vec<'arena, u16>,

	/// Handles to content signatures of symbols
	///
	/// One of the most critical tasks of the compiler would be to do name resolution and type resolution.
	/// Thus we need to store the type signatures in a way that is efficient to read, write, and analyse.
	/// While the primitive types (such as usize, float, str) will be stored directly,
	/// The type signature of external types will be stored as relative links.
	///
	/// That is,
	/// In function signature `fn add(x,y foo.Bar) foo.Bar`, we will not resolve the type `foo.Bar` directly.
	/// Instead we choose to store it as `foo.Bar` so we can do fast dependency analysis and incremental compilation.
	///
	/// Thus we need to know for any symbol what kind of content is responsible for its signature.
	/// While the identifiers, return types etc. form a part of the signature, we also need to analyse its content.
	/// For functions this content will be the argument signature, while for structs it will be the values contained
	/// within the struct.
	///
	/// While this may seem confusing at the beginning just think of it as a generic way for us to represent different
	/// constructs such as functions/structs in a single unified representation. This generic representation using
	/// content signature allows us to simplify our data and code.
	pub symbol_content: Arena::Vec<'arena, SymbolContent>,

	/// Handle to contexts of symbols.
	///
	/// The contexts will contain all of the necessary data stored within the symbols.
	/// A function's context will contain the AST of the function, its local variables, its ownership etc.
	///
	/// Since the contexts will be extremely large in size, we can not store them as an object within this struct.
	/// Thus for safer decoupling we just store their handles so we can access them later on.
	pub symbol_context: Arena::Vec<'arena, SymbolContext>,

	/// Meta data
	pub meta_data: MetaData,
}

/// Abstract syntax tree context
pub struct Context {
	//
}

/// Reference to everything used within the Abstract syntax tree
pub struct Reference {
	//
}

#[derive(Debug)]
pub struct SymbolContent {
	content_head_index: u16,
	len: u16,
}

#[derive(Debug)]
pub struct SymbolContext {
	context_head_index: u16,
	len: u16,
}

#[derive(Debug)]
pub struct MetaData {
	num_modules: usize,
	num_functions: usize,
	num_structs: usize,
}

/// Nodes of Abstract Syntax Tree
#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, EnumAsInner)]
pub enum Nodes {
	Documentation = 0,
	Comment,
	Module,
	Function,
	Struct,
	Enum,
	Assignment,
	Value,
	Expression,
	Visible,
	Hidden,
	Constant,
	Variable,
	Argument,
	Block,
	Identifier,
	Unit,
	Usize,
	Float,
	Str,
	Start,
	End,
}

pub fn calculate_ast_signature_step1<'arena>(
	arena: &'arena Arena::Allocator,
	ast: &'arena [Nodes],
	identifiers: &'arena [&str],
) -> Result<Signature<'arena>> {
	// Count the number of entities so we can pre-allocate memory in arena
	let num_modules = ast.iter().filter(|&node| node.is_module()).count();
	let num_functions = ast.iter().filter(|&node| node.is_function()).count();
	let num_structs = ast.iter().filter(|&node| node.is_struct()).count();
	let num_entities = num_modules + num_functions + num_structs;

	let mut signature = {
		let symbol_identifiers = Arena::Vec::<&str>::with_capacity_in(num_entities, arena);
		let symbol_kinds = Arena::Vec::<Nodes>::with_capacity_in(num_entities, arena);
		let symbol_byte_sizes = Arena::Vec::<u16>::with_capacity_in(num_entities, arena);
		let symbol_content = Arena::Vec::<SymbolContent>::with_capacity_in(num_entities, arena);
		let symbol_context = Arena::Vec::<SymbolContext>::with_capacity_in(num_entities, arena);
		let signature = Signature {
			symbol_identifiers,
			symbol_kinds,
			symbol_sizes: symbol_byte_sizes,
			symbol_content,
			symbol_context,
			meta_data: MetaData {
				num_modules,
				num_functions,
				num_structs,
			},
		};
		signature
	};

	let mut identifiers = identifiers.iter().peekable();

	for &node in ast.iter() {
		if node.is_module() || node.is_function() || node.is_struct() {
			let identifier = identifiers.peek().unwrap();
			let kind = node;
			let size = 0;
			signature.symbol_identifiers.push(identifier);
			signature.symbol_kinds.push(kind);
			signature.symbol_sizes.push(size);
			identifiers.next();
		}
	}

	Ok(signature)
}

pub fn calculate_ast_signature_step2<'arena>(
	arena: &'arena Arena::Allocator,
	ast: &'arena [Nodes],
	identifiers: &'arena [&str],
	mut signature: Signature<'arena>,
) -> Result<Signature<'arena>> {
	Ok(signature)
}

#[cfg(test)]
mod utest {
	use super::*;

	#[test]
	fn test_ast() -> Result<()> {
		let arena = Arena::Allocator::new();
		let ast = Arena::vec![in &arena;
			Nodes::Documentation,
			Nodes::Function,
			Nodes::Start,
			Nodes::Identifier,
			Nodes::Hidden,
			Nodes::Unit,
			Nodes::Argument,
			Nodes::Start,
			Nodes::End,
			Nodes::Block,
			Nodes::Start,
			Nodes::Comment,
			Nodes::End,
		];
		let documentations = Arena::vec![in &arena; "/// Driver code\n"];
		let comments = Arena::vec![in &arena; "// * code goes here *\n"];
		let identifiers = Arena::vec![in &arena; "main"];
		let signature = calculate_ast_signature_step1(&arena, &ast, &identifiers)?;
		let signature = calculate_ast_signature_step2(&arena, &ast, &identifiers, signature)?;
		dbg!(signature);
		Ok(())
	}
}
