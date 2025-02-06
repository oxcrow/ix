#pragma once

enum TokenType : u8 {
    TokenUnknown,

    TokenComment,  // //
    TokenUse,      // use
    TokenLet,      // let
    TokenVar,      // var
    TokenFn,       // fn
    TokenStruct,   // struct
    TokenEnum,     // enum

    TokenReturn,  // return
    TokenExtern,  // extern
    TokenAlias,   // alias
    TokenWhile,   // while
    TokenFor,     // for
    TokenIf,      // if
    TokenElse,    // else
    TokenSwitch,  // switch
    TokenCase,    // case
    TokenCast,    // cast
    TokenSame,    // same
    TokenAs,      // as
    TokenIn,      // in

    TokenSemicolon,  // ;
    TokenColon,      // :
    TokenComma,      // ,
    TokenDot,        // .
    TokenHash,       // #
    TokenAt,         // @
    TokenAmpersand,  // &
    TokenQuestion,   // ?
    TokenDollar,     // $
    TokenCaret,      // ^

    TokenLeftxParenthesis,  // (
    TokenRightParenthesis,  // )
    TokenLeftxBracket,      // [
    TokenRightBracket,      // ]
    TokenLeftxBrace,        // {
    TokenRightBrace,        // }
    TokenLeftxAngle,        // <
    TokenRightAngle,        // >
    TokenLeftxArrow,        // <-
    TokenRightArrow,        // ->

    TokenLogicalNot,  //  !
    TokenLogicalAnd,  // &&
    TokenLogicalOr,   // ||
    TokenPlus,        // +
    TokenPlusPlus,    // ++
    TokenMinus,       // -
    TokenMinusMinus,  // --
    TokenStar,        // *
    TokenStarStar,    // **
    TokenSlash,       // /

    TokenEqual,             // =
    TokenEqualEqual,        // ==
    TokenNotEqual,          // !=
    TokenLessThan,          // +<
    TokenGreaterThan,       // +>
    TokenLessThanEqual,     // +<=
    TokenGreaterThanEqual,  // +>=

    TokenAny,   // any
    TokenVoid,  // void

    TokenI8,   // i8
    TokenU8,   // u8
    TokenI16,  // i16
    TokenU16,  // u16
    TokenI32,  // i32
    TokenU32,  // u32
    TokenI64,  // i64
    TokenU64,  // u64
    TokenF32,  // f32
    TokenF64,  // f64
};
