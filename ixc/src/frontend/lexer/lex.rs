use anyhow::ensure;
use anyhow::Result;
//
use arrayvec::ArrayVec as Array;

/// Tokens of our code
#[repr(u8)]
#[derive(Debug, PartialEq)]
pub enum Tokens {
	Unknown,
	Whitespace,
	Comment, // //

	// Statements
	Use,    // use
	Let,    // let
	Mod,    // mod
	Macro,  // macro
	Fn,     // fn
	Struct, // struct
	Enum,   // enum

	Return, // return
	While,  // while
	For,    // for
	If,     // if
	Else,   // else
	Switch, // switch
	Case,   // case

	// Symbols
	Newline,          // \n, \r, or \r\n
	Semicolon,        // ;
	ColonEqual,       // :=
	EqualEqual,       // ==
	NotEqual,         // !=
	Equal,            // =
	LessThan,         // +<
	GreaterThan,      // +>
	LessThanEqual,    // +<=
	GreaterThanEqual, // +>=
	LogicalNot,       // !!
	LogicalAnd,       // &&
	LogicalOr,        // ||
	ColonColon,       // ::
	Colon,            // :
	DotDotDot,        // ...
	DotDot,           // ..
	Dot,              // .
	PlusPlus,         // ++
	MinusMinus,       // --
	StarStar,         // **
	Plus,             // +
	Minus,            // -
	Star,             // *
	Caret,            // ^
	Hash,             // #
	Dollar,           // $
	Exclamation,      // !
	Question,         // ?

	LParen, // (
	RParen, // )
	LBrace, // {
	RBrace, // }
	LBrack, // [
	RBrack, // ]
	LAngle, // <
	RAngle, // >

	// Types
	Unit, //
	Any,  // any
	Int,  // int
	Flt,  // flt

	I8,  // i8
	U8,  // u8
	I16, // i16
	U16, // u16
	I32, // i32
	U32, // u32
	I64, // i64
	U64, // u64
	F32, // f32
	F64, // f64

	// Complex
	IntVal, // ints: [0-9_]+
	FltVal, // floats: we really need to think about this ...
	Id,     // identifiers: [a-zA-Z_][a-zA-Z0-9_]+
}

pub mod Searchers {
	const NIL: (bool, usize) = (false, 0);

	pub fn line_length(code: &str) -> usize {
		code.chars().position(|c| c == '\n' || c == '\r').unwrap() + 1
	}

	pub fn search_whitespace(code: &str, _: &str) -> (bool, usize) {
		let a = code.chars().nth(0);
		match a {
			| Some(' ') | Some('\t') => (true, 1),
			| _ => NIL,
		}
	}

	pub fn search_newline(code: &str) -> (bool, usize) {
		let a = code.chars().nth(0);
		let b = code.chars().nth(1);
		match (a, b) {
			| (Some('\n') | Some('\r'), Some('\n')) => (true, 1),
			| _ => NIL,
		}
	}

	pub fn search_comment(code: &str) -> (bool, usize) {
		let a = code.chars().nth(0);
		let b = code.chars().nth(1);
		match (a, b) {
			| (Some('/'), Some('/')) => (true, line_length(code)),
			| (_, _) => NIL,
		}
	}

	pub fn search_token(code: &str, token: &str) -> (bool, usize) {
		let token_length = token.len();
		// Skip if the current token is too long.
		if code.len() < token_length {
			return (false, 0);
		}
		let slice = &code[0..token_length];
		match slice == token {
			| true => (true, token_length),
			| false => (false, 0),
		}
	}
}

pub fn lex_line(code: &str) -> Result<(Array<Tokens, 128>, &str)> {
	use Searchers::*;

	// Stack allocated data containers
	// Note: Since our lexer needs to be *extremely* fast we can not
	// allocae memory on heap. To further clarify, we should not do
	// anything related to system kernel calls because calling the
	// kernel is a slow process, and most heap memory allocators
	// calling the kernel to allocate memory.
	// Thus we allocate memory on the stack.
	let mut tokens = Array::<Tokens, 128>::new();
	let mut word = Array::<char, 128>::new();

	// Extract the line of code so we can process it as a segment
	// BUG: This can not identify "\r\n" line endings on Windows. Fix!
	let line_length = {
		let length = code.chars().position(|c| c == '\n' || c == '\r');
		let length = match length {
			| Some(x) => x + 1,
			| None => 1,
		};
		length
	};

	// The current line.
	//
	// The tokens will be identified one by one and the section of the
	// line that has been tokenized, will be cut off, and the
	// remainder of the line will be returned.
	//
	// This will allow us to tokenize one by one and avoid
	// re-tokenizing the same token again and again by mistake.
	let mut line = &code[0..line_length];

	fn lex_next_token<'a>(line: &'a str, expected_token: Tokens) -> (Tokens, &'a str) {
		use Tokens::*;
		let (found_token, token_length) = match expected_token {
			| Whitespace => search_whitespace(line, ""),
			| Comment => search_comment(line),
			| Use => search_token(line, "use"),
			| Let => search_token(line, "let"),
			| Mod => search_token(line, "mod"),
			| Macro => search_token(line, "macro"),
			| Fn => search_token(line, "fn"),
			| Struct => search_token(line, "struct"),
			| Enum => search_token(line, "enum"),
			| Return => search_token(line, "return"),
			| While => search_token(line, "while"),
			| If => search_token(line, "if"),
			| Else => search_token(line, "else"),
			| Switch => search_token(line, "switch"),
			| Case => search_token(line, "case"),
			| Semicolon => search_token(line, ";"),
			| ColonEqual => search_token(line, ":="),
			| EqualEqual => search_token(line, "=="),
			| NotEqual => search_token(line, "!="),
			| Equal => search_token(line, "="),
			| LessThan => search_token(line, "+<"),
			| GreaterThan => search_token(line, "+>"),
			| LessThanEqual => search_token(line, "+<="),
			| GreaterThanEqual => search_token(line, "+>="),
			| LogicalNot => search_token(line, "!!"),
			| LogicalAnd => search_token(line, "&&"),
			| LogicalOr => search_token(line, "||"),
			| ColonColon => search_token(line, "::"),
			| Colon => search_token(line, ":"),
			| DotDotDot => search_token(line, "..."),
			| DotDot => search_token(line, ".."),
			| Dot => search_token(line, "."),
			| PlusPlus => search_token(line, "++"),
			| MinusMinus => search_token(line, "--"),
			| StarStar => search_token(line, "**"),
			| Plus => search_token(line, "+"),
			| Minus => search_token(line, "-"),
			| Star => search_token(line, "*"),
			| Caret => search_token(line, "^"),
			| Hash => search_token(line, "#"),
			| Dollar => search_token(line, "$"),
			| Exclamation => search_token(line, "!"),
			| Question => search_token(line, "?"),
			| LParen => search_token(line, "("),
			| RParen => search_token(line, ")"),
			| LBrace => search_token(line, "{"),
			| RBrace => search_token(line, "}"),
			| LBrack => search_token(line, "["),
			| RBrack => search_token(line, "]"),
			| LAngle => search_token(line, "<"),
			| RAngle => search_token(line, ">"),
			| Unit => search_token(line, "<>"),
			| Any => search_token(line, "any"),
			| Int => search_token(line, "int"),
			| Flt => search_token(line, "flt"),
			| I8 => search_token(line, "i8"),
			| U8 => search_token(line, "u8"),
			| I16 => search_token(line, "i16"),
			| U16 => search_token(line, "u16"),
			| I32 => search_token(line, "i32"),
			| U32 => search_token(line, "u32"),
			| I64 => search_token(line, "i64"),
			| U64 => search_token(line, "u64"),
			| F32 => search_token(line, "f32"),
			| F64 => search_token(line, "f64"),
			| Id => search_token(line, "main"),
			| _ => (false, 0),
		};
		if found_token {
			(expected_token, &line[token_length..])
		} else {
			(Tokens::Unknown, line)
		}
	}

	fn tokenize<'a>(
		line: &'a str,
		found: &mut bool,
		tokens: &mut Array<Tokens, 128>,
		expected_token: Tokens,
	) -> &'a str {
		// If we have finished reading everything then we succeeded.
		// If we already found the token then we suceeded.
		// We can return as we have nothing else to do.
		if line.is_empty() || *found == true {
			return line;
		}
		let (token, line) = lex_next_token(line, expected_token);
		if token != Tokens::Unknown && token != Tokens::Whitespace {
			*found = true;
			tokens.push(token);
		}
		line
	}

	// Safety checks to prevent infinite loop
	let mut iter = 0;

	// Lex until the end of line
	'outer: while !line.is_empty() && iter < line_length {
		use Tokens::*;

		iter += 1;
		let mut found = false;

		line = tokenize(line, &mut found, &mut tokens, Whitespace);
		line = tokenize(line, &mut found, &mut tokens, Comment);

		if !found {
			line = tokenize(line, &mut found, &mut tokens, Use);
			line = tokenize(line, &mut found, &mut tokens, Let);
			line = tokenize(line, &mut found, &mut tokens, Mod);
			line = tokenize(line, &mut found, &mut tokens, Macro);
			line = tokenize(line, &mut found, &mut tokens, Fn);
			line = tokenize(line, &mut found, &mut tokens, Struct);
			line = tokenize(line, &mut found, &mut tokens, Enum);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, Return);
			line = tokenize(line, &mut found, &mut tokens, While);
			line = tokenize(line, &mut found, &mut tokens, For);
			line = tokenize(line, &mut found, &mut tokens, If);
			line = tokenize(line, &mut found, &mut tokens, Else);
			line = tokenize(line, &mut found, &mut tokens, Switch);
			line = tokenize(line, &mut found, &mut tokens, Case);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, LParen);
			line = tokenize(line, &mut found, &mut tokens, RParen);
			line = tokenize(line, &mut found, &mut tokens, LBrace);
			line = tokenize(line, &mut found, &mut tokens, RBrace);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, Semicolon);
			line = tokenize(line, &mut found, &mut tokens, ColonEqual);
			line = tokenize(line, &mut found, &mut tokens, EqualEqual);
			line = tokenize(line, &mut found, &mut tokens, NotEqual);
			line = tokenize(line, &mut found, &mut tokens, Equal);
			line = tokenize(line, &mut found, &mut tokens, LessThan);
			line = tokenize(line, &mut found, &mut tokens, GreaterThan);
			line = tokenize(line, &mut found, &mut tokens, LessThanEqual);
			line = tokenize(line, &mut found, &mut tokens, GreaterThanEqual);
			line = tokenize(line, &mut found, &mut tokens, LogicalNot);
			line = tokenize(line, &mut found, &mut tokens, LogicalAnd);
			line = tokenize(line, &mut found, &mut tokens, LogicalOr);
			line = tokenize(line, &mut found, &mut tokens, ColonColon);
			line = tokenize(line, &mut found, &mut tokens, Colon);
			line = tokenize(line, &mut found, &mut tokens, DotDotDot);
			line = tokenize(line, &mut found, &mut tokens, DotDot);
			line = tokenize(line, &mut found, &mut tokens, Dot);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, PlusPlus);
			line = tokenize(line, &mut found, &mut tokens, MinusMinus);
			line = tokenize(line, &mut found, &mut tokens, StarStar);
			line = tokenize(line, &mut found, &mut tokens, Plus);
			line = tokenize(line, &mut found, &mut tokens, Minus);
			line = tokenize(line, &mut found, &mut tokens, Star);
			line = tokenize(line, &mut found, &mut tokens, Caret);
			line = tokenize(line, &mut found, &mut tokens, Hash);
			line = tokenize(line, &mut found, &mut tokens, Dollar);
			line = tokenize(line, &mut found, &mut tokens, Exclamation);
			line = tokenize(line, &mut found, &mut tokens, Question);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, Unit);
			line = tokenize(line, &mut found, &mut tokens, Any);
			line = tokenize(line, &mut found, &mut tokens, Int);
			line = tokenize(line, &mut found, &mut tokens, Flt);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, I8);
			line = tokenize(line, &mut found, &mut tokens, U8);
			line = tokenize(line, &mut found, &mut tokens, I16);
			line = tokenize(line, &mut found, &mut tokens, U16);
			line = tokenize(line, &mut found, &mut tokens, I32);
			line = tokenize(line, &mut found, &mut tokens, U32);
			line = tokenize(line, &mut found, &mut tokens, I64);
			line = tokenize(line, &mut found, &mut tokens, U64);
			line = tokenize(line, &mut found, &mut tokens, F32);
			line = tokenize(line, &mut found, &mut tokens, F64);
		} else {
			continue 'outer;
		}

		if !found {
			line = tokenize(line, &mut found, &mut tokens, Id);
		}
	}

	Ok((tokens, &code[line_length..]))
}
