# reasons

I will try to note down the reasons behind different decisions made
while developing the Ix language. Since users are always demanding
more and more new features (like C++), it might become troublesome
for us to help them understand that it is not beneficial for us to
implement new features forever, and many things they want may actually
be bad.

- Why is the language so simple?

  Most of the questions regarding Ix can most definitely be answered
  by saying "We want a simple language that is extremely easy to
  parse, and lightning fast to compile, so that developer productivity
  tools such as LSPs, linters, formatters, etc. can be developed with
  ease, and the tools developed can be efficient, and never require
  absurd amounts of system resources to run."

  This is the primary reason behind why Ix is a simple language.

- Why is everything statically typed?

  Static types allows us to write safe code.

  While dynamic typing like those in Python and type inference in
  Rust can be useful from time to time, they are somewhat prone to
  being abused by the users. Python for example is notorious for its
  runtime errors which originate due to its fragile type system.
  Rust's type inference is somewhat better since the types are
  determined at compile time, but in some cases it makes the code
  harder to understand.In the worst case example, JavaScript's
  type system is even more fragile than Python's and has caused
  tremendous suffering to those who had to code in it.

  This is evidently proven by the fact that to save JavaScript
  developers new languages were developed that add static types. At
  the same time we do not deny that some times type inference can be
  useful, such as when we do not want to type out the complex types
  generated due to generics, macros, or template meta programming.
  Thus we will have to make the harsh decision that type inference can
  not be allowed, and instead the users must decorate their code with
  static types.

  Static types are good.

- Why does the code's syntax look like C?

  I like coding in C.

  Even though Rust, Zig, C++, and other advanced languages have more
  advanced syntax, they are slightly harder to type. In comparison to
  them typing C code is fast. While this is my personal anecdotal
  opinion it is also based on truth.

  Thus Ix will mostly follow C syntax.
