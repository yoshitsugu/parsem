test "char" {
  inspect!(
    @parsem.parse(@parsem.char('a'), "abc"),
    content="ParseResult(Ok(('a', @list.of(['b', 'c']))))",
  )
  inspect!(
    @parsem.parse(@parsem.char('a'), "bcd"),
    content="ParseResult(Err(Parse Error: expected 'a'))",
  )
}

test "string" {
  inspect!(
    @parsem.parse(@parsem.string("abc"), "abcde"),
    content="ParseResult(Ok((\"abc\", @list.of(['d', 'e']))))",
  )
  inspect!(
    @parsem.parse(@parsem.string("abc"), "bcd"),
    content="ParseResult(Err(Parse Error: expected \"abc\"))",
  )
}

test "digit" {
  inspect!(
    @parsem.parse(@parsem.digit(), "123abc"),
    content="ParseResult(Ok(('1', @list.of(['2', '3', 'a', 'b', 'c']))))",
  )
  inspect!(
    @parsem.parse(@parsem.digit(), "abc123"),
    content="ParseResult(Err(Parse Error: expected digit))",
  )
}

test "digits" {
  let result : @parsem.ParseResult[Int] = @parsem.parse(
    @parsem.digits(),
    "123abc",
  )
  inspect!(result, content="ParseResult(Ok((123, @list.of(['a', 'b', 'c']))))")
  let result2 : @parsem.ParseResult[Int] = @parsem.parse(
    @parsem.digits(),
    "abc123",
  )
  inspect!(result2, content="ParseResult(Err(Parse Error: expected digit))")
}
