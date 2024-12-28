///|
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
