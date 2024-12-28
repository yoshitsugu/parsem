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
