use criterion::{black_box, criterion_group, criterion_main, Criterion};
//
use ixc::frontend::lexer::lex;

fn lexer(c: &mut Criterion) {
    let code = std::fs::read_to_string("src/main.ix").unwrap();

    fn lex_line(code: String) {
        let code = black_box(code);
        let (_, _) = lex::lex_line(&code).unwrap();
    }

    c.bench_function("lexer-lex-line", |b| b.iter(|| lex_line(code.clone())));
}

criterion_group!(benches, lexer);
criterion_main!(benches);
