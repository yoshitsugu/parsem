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

///|
/// Applies 2 parsers until any parser fails.
/// Returns tuple of the result of the parsers.
pub fn sequence[T1, T2](
  parser1 : Parser[T1],
  parser2 : Parser[T2]
) -> Parser[(T1, T2)] {
  return Parser(fn(input : CList) -> ParseResult[(T1, T2)] {
    match parse(parser1, input)._ {
      Ok((p1, r1)) =>
        match parse(parser2, r1)._ {
          Ok((p2, r2)) => Ok(((p1, p2), r2))
          Err(err) => Err(err)
        }
      Err(err) => Err(err)
    }
  })
}

///| |
/// Applies 3 parsers until any parser fails.
/// Returns tuple of the result of the parsers.
pub fn sequence3[T1, T2, T3](
  parser1 : Parser[T1],
  parser2 : Parser[T2],
  parser3 : Parser[T3]
) -> Parser[(T1, T2, T3)] {
  return Parser(fn(input : CList) -> ParseResult[(T1, T2, T3)] {
    match parse(sequence(sequence(parser1, parser2), parser3), input)._ {
      Ok((((p1, p2), p3), r1)) => Ok(((p1, p2, p3), r1))
      Err(err) => Err(err)
    }
  })
}

///|
/// Applies **zero** or more occurrences of `parser` separated by `sep_by`.
/// Returns a immutable list of the values returned by the `parser`.
pub fn sep_by[T, U](
  parser : Parser[T],
  sep_by : Parser[U]
) -> Parser[@immut/list.T[T]] {
  return Parser(fn(input : CList) -> ParseResult[@immut/list.T[T]] {
    match parse(sep_by1(parser, sep_by), input)._ {
      Ok(_) as ok => ok
      Err(_) => Ok((@immut/list.from_array([]), input))
    }
  })
}

///|
/// Applies **one** or more occurrences of `parser` separated by `sep_by`.
/// Returns a immutable list of the values returned by the `parser`.
pub fn sep_by1[T, U](
  parser : Parser[T],
  sep_by : Parser[U]
) -> Parser[@immut/list.T[T]] {
  return Parser(fn(input : CList) -> ParseResult[@immut/list.T[T]] {
    fn _sep_by(input_ : CList) -> (@immut/list.T[T], CList) {
      match parse(sequence(sep_by, parser), input_) {
        ParseResult(Ok(((_, parsed), rest))) => {
          let (new_result, new_rest) = _sep_by(rest)
          (@immut/list.from_array([parsed]).concat(new_result), new_rest)
        }
        ParseResult(Err(_)) => (@immut/list.from_array([]), input_)
      }
    }

    match parse(parser, input)._ {
      Ok((parsed, rest)) => {
        let (new_parsed, new_rest) = _sep_by(rest)
        Ok((@immut/list.from_array([parsed]).concat(new_parsed), new_rest))
      }
      Err(err) => Err(err)
    }
  })
}

///|
/// Applies two parsers sequentially until one of them fails.
/// Returns the result of the last successful parser.
pub fn then[T, U](self : Parser[T], next_parser : Parser[U]) -> Parser[U] {
  return Parser(fn(input : CList) -> ParseResult[U] {
    match parse(sequence(self, next_parser), input)._ {
      Ok(((_, next_result), rest)) => Ok((next_result, rest))
      Err(err) => Err(err)
    }
  })
}

///|
/// Applies two parsers sequentially until one of them fails.
/// Returns the result of the first successful parser(self).
pub fn precede[T, U](self : Parser[T], next_parser : Parser[U]) -> Parser[T] {
  return Parser(fn(input : CList) -> ParseResult[T] {
    match parse(sequence(self, next_parser), input)._ {
      Ok(((result, _), rest)) => Ok((result, rest))
      Err(err) => Err(err)
    }
  })
}

///|
/// Tries to apply the parser. If it fails without consuming input, it returns the value `fallback_value`,
/// otherwise the value returned by the parser
pub fn option[T](fallback_value : T, parser : Parser[T]) -> Parser[T] {
  return Parser(fn(input : CList) -> ParseResult[T] {
    match parse(parser, input)._ {
      Ok((result, rest)) => Ok((result, rest))
      Err(_) => Ok((fallback_value, input))
    }
  })
}

///|
/// Transforms the result of the parser using the provided function.
pub fn map[T, U](self : Parser[T], func : (T) -> U) -> Parser[U] {
  return Parser(fn(input : CList) -> ParseResult[U] {
    match parse(self, input)._ {
      Ok((result, rest)) => Ok((func(result), rest))
      Err(err) => Err(err)
    }
  })
}

///|
/// Chains parsers by applying a function to the result of the first parser
/// to produce the next parser.
pub fn bind[T, U](self : Parser[T], func : (T) -> Parser[U]) -> Parser[U] {
  return Parser(fn(input : CList) -> ParseResult[U] {
    match parse(self, input)._ {
      Ok((result, rest)) => parse(func(result), rest)
      Err(err) => Err(err)
    }
  })
}
