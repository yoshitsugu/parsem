test "char" {
  inspect(
    @parsem.parse(@parsem.char('a'), "abc"),
    content="Ok(('a', @list.from_array(['b', 'c'])))",
  )
  inspect(
    @parsem.parse(@parsem.char('a'), "bcd"),
    content="Err(Parse Error: expected 'a')",
  )
}

test "string" {
  inspect(
    @parsem.parse(@parsem.string("abc"), "abcde"),
    content="Ok((\"abc\", @list.from_array(['d', 'e'])))",
  )
  inspect(
    @parsem.parse(@parsem.string("abc"), "bcd"),
    content="Err(Parse Error: expected \"abc\")",
  )
}

test "digit" {
  inspect(
    @parsem.parse(@parsem.digit(), "123abc"),
    content="Ok(('1', @list.from_array(['2', '3', 'a', 'b', 'c'])))",
  )
  inspect(
    @parsem.parse(@parsem.digit(), "abc123"),
    content="Err(Parse Error: expected digit)",
  )
}

test "digits" {
  let result : @parsem.ParseResult[Int] = @parsem.parse(
    @parsem.digits(),
    "123abc",
  )
  inspect(result, content="Ok((123, @list.from_array(['a', 'b', 'c'])))")
  let result2 : @parsem.ParseResult[Int] = @parsem.parse(
    @parsem.digits(),
    "abc123",
  )
  inspect(result2, content="Err(Parse Error: expected digit)")
}
