test "many matches many" {
  let result = @parsem.parse(@parsem.many(@parsem.char('a')), "aaaabc")
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['a', 'a', 'a', 'a'])
  assert_eq!(rest.to_array(), ['b', 'c'])
}

test "many matches zero" {
  let result = @parsem.parse(@parsem.many(@parsem.char('a')), "b")
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), [])
  assert_eq!(rest.to_array(), ['b'])
}

test "many matches one" {
  let result = @parsem.parse(@parsem.many(@parsem.char('a')), "ab")
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['a'])
  assert_eq!(rest.to_array(), ['b'])
}

test "many1 matches many" {
  let result = @parsem.parse(@parsem.many1(@parsem.char('a')), "aaaabc")
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['a', 'a', 'a', 'a'])
  assert_eq!(rest.to_array(), ['b', 'c'])
}

test "many1 doesn't match zero" {
  let result = @parsem.parse(@parsem.many1(@parsem.char('a')), "b")
  assert_true!(result._.is_err())
}

test "many1 matches one" {
  let result = @parsem.parse(@parsem.many1(@parsem.char('a')), "ab")
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['a'])
  assert_eq!(rest.to_array(), ['b'])
}

test "choice matches first parser" {
  let result = @parsem.parse(
    @parsem.choice([@parsem.char('a'), @parsem.char('b')]),
    "ab",
  )
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed, 'a')
  assert_eq!(rest.to_array(), ['b'])
}

test "choice matches second parser" {
  let result = @parsem.parse(
    @parsem.choice([@parsem.char('a'), @parsem.char('b')]),
    "ba",
  )
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed, 'b')
  assert_eq!(rest.to_array(), ['a'])
}

test "choice returns the last error if no parses matched" {
  let result = @parsem.parse(
    @parsem.choice([@parsem.char('a'), @parsem.char('b')]),
    "ccc",
  )
  inspect!(result, content="ParseResult(Err(Parse Error: expected 'b'))")
}

test "sequence" {
  let result = @parsem.parse(
    @parsem.sequence(@parsem.char('a'), @parsem.char('b')),
    "abcd",
  )
  inspect!(
    result,
    content="ParseResult(Ok((('a', 'b'), @list.of(['c', 'd']))))",
  )
}

test "sequence3" {
  let result : @parsem.ParseResult[(Char, Char, Int)] = @parsem.parse(
    @parsem.sequence3(@parsem.char('a'), @parsem.char('b'), @parsem.digits()),
    "ab123cd",
  )
  inspect!(
    result,
    content="ParseResult(Ok((('a', 'b', 123), @list.of(['c', 'd']))))",
  )
}

test "sep_by matches many" {
  let result = @parsem.parse(
    @parsem.sep_by(@parsem.digit(), @parsem.char(',')),
    "3,4,5abc",
  )
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['3', '4', '5'])
  assert_eq!(rest.to_array(), ['a', 'b', 'c'])
}

test "sep_by matches zero" {
  let result = @parsem.parse(
    @parsem.sep_by(@parsem.digit(), @parsem.char(',')),
    "b",
  )
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), [])
  assert_eq!(rest.to_array(), ['b'])
}

test "sep_by matches one" {
  let result = @parsem.parse(
    @parsem.sep_by(@parsem.digit(), @parsem.char(',')),
    "1ab",
  )
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['1'])
  assert_eq!(rest.to_array(), ['a', 'b'])
}

test "sep_by1 matches many" {
  let result = @parsem.parse(
    @parsem.sep_by1(@parsem.digit(), @parsem.char(',')),
    "3,4,5abc",
  )
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['3', '4', '5'])
  assert_eq!(rest.to_array(), ['a', 'b', 'c'])
}

test "sep_by1 doesn't match zero" {
  let result = @parsem.parse(
    @parsem.sep_by1(@parsem.digit(), @parsem.char(',')),
    "b",
  )
  assert_true!(result._.is_err())
}

test "sep_by1 matches one" {
  let result = @parsem.parse(
    @parsem.sep_by1(@parsem.digit(), @parsem.char(',')),
    "1ab",
  )
  assert_true!(result._.is_ok())
  let (parsed, rest) = result._.unwrap()
  assert_eq!(parsed.to_array(), ['1'])
  assert_eq!(rest.to_array(), ['a', 'b'])
}

test "then" {
  let result = @parsem.parse(@parsem.char('a').then(@parsem.char('b')), "abcd")
  inspect!(result, content="ParseResult(Ok(('b', @list.of(['c', 'd']))))")
}

test "precede" {
  let result = @parsem.parse(
    @parsem.char('a').precede(@parsem.char('b')),
    "abcd",
  )
  inspect!(result, content="ParseResult(Ok(('a', @list.of(['c', 'd']))))")
}

test "option" {
  inspect!(
    @parsem.parse(@parsem.option('z', @parsem.char('a')), "abc"),
    content="ParseResult(Ok(('a', @list.of(['b', 'c']))))",
  )
  inspect!(
    @parsem.parse(@parsem.option('z', @parsem.char('a')), "efg"),
    content="ParseResult(Ok(('z', @list.of(['e', 'f', 'g']))))",
  )
}

test "map" {
  inspect!(
    @parsem.parse(
      @parsem.map(@parsem.char('a'), fn(c : Char) -> String { "\{c}\{c}" }),
      "abc",
    ),
    content="ParseResult(Ok((\"aa\", @list.of(['b', 'c']))))",
  )
}

test "bind with complex example" {
  enum Expr {
    IntValue(Int)
    Add(Expr, Expr)
    Mul(Expr, Expr)
  } derive(Show)
  fn int_value() -> @parsem.Parser[Expr] {
    @parsem.map(@parsem.digits(), fn(digits : Int) { IntValue(digits) })
  }

  fn add() -> @parsem.Parser[Expr] {
    mul().bind(fn(expr1 : Expr) {
      @parsem.option(
        expr1,
        @parsem.many(@parsem.char(' '))
        .then(@parsem.char('+'))
        .then(@parsem.many(@parsem.char(' ')))
        .then(mul())
        .map(fn(expr2) { Add(expr1, expr2) }),
      )
    })
  }

  fn mul() -> @parsem.Parser[Expr] {
    expr().bind(fn(expr1 : Expr) {
      @parsem.option(
        expr1,
        @parsem.many(@parsem.char(' '))
        .then(@parsem.char('*'))
        .then(@parsem.many(@parsem.char(' ')))
        .then(expr())
        .map(fn(expr2) { Mul(expr1, expr2) }),
      )
    })
  }

  // To avoid infinite loops, @parsem.choice cannot be used in this context.
  fn expr() -> @parsem.Parser[Expr] {
    return @parsem.Parser(fn(input) {
      match @parsem.parse(@parsem.char('('), input)._ {
        Ok((_, rest)) => @parsem.parse(add().precede(@parsem.char(')')), rest)
        Err(_) => @parsem.parse(int_value(), input)
      }
    })
  }

  inspect!(
    @parsem.parse(add(), "1 + 2"),
    content="ParseResult(Ok((Add(IntValue(1), IntValue(2)), @list.of([]))))",
  )
  inspect!(
    @parsem.parse(expr(), "((12 +  24) * 2)"),
    content="ParseResult(Ok((Mul(Add(IntValue(12), IntValue(24)), IntValue(2)), @list.of([]))))",
  )
}
