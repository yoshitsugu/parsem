///|
/// Applies the parser **zero** or more times.
/// Returns a immutable list of the returned values of parser.
pub fn many[T](parser : Parser[T]) -> Parser[@immut/list.T[T]] {
  return Parser(fn(input : CList) -> ParseResult[@immut/list.T[T]] {
    fn _many(input_ : CList) -> (@immut/list.T[T], CList) {
      match parse(parser, input_) {
        ParseResult(Ok((parsed, rest))) => {
          let (new_result, new_rest) = _many(rest)
          (@immut/list.from_array([parsed]).concat(new_result), new_rest)
        }
        ParseResult(Err(_)) => (@immut/list.from_array([]), input_)
      }
    }

    Ok(_many(input))
  })
}

///|
/// Applies the parser **one** or more times.
/// Returns a immutable list of the returned values of parser.
pub fn many1[T](parser : Parser[T]) -> Parser[@immut/list.T[T]] {
  return Parser(fn(input : CList) -> ParseResult[@immut/list.T[T]] {
    match parse(parser, input) {
      ParseResult(Ok((parsed, rest))) =>
        match parse(many(parser), rest)._ {
          Ok((new_parsed, new_rest)) =>
            Ok((@immut/list.from_array([parsed]).concat(new_parsed), new_rest))
          err => err
        }
      ParseResult(Err(err)) => Err(err)
    }
  })
}

///|
/// Applies the array of parsers one by one until one of them succeeds.
/// Returns the value of the succeeding parser.
pub fn choice[T](parsers : Array[Parser[T]]) -> Parser[T] {
  return Parser(fn(input : CList) -> ParseResult[T] {
    if parsers.length() == 0 {
      return Err(NonEmptyArrayIsRequiredError)
    }
    let mut result = Err(UnreachableError)
    for parser in parsers {
      match parse(parser, input)._ {
        Ok(ok_result) => {
          result = Ok(ok_result)
          break
        }
        Err(err) => result = Err(err)
      }
    }
    result
  })
}
