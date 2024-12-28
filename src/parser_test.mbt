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
