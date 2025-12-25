///|
pub suberror ParseError {
  ParseCharError(expected~ : Char)
  ParseStringError(expected~ : String)
  ParseDigitError
  NonEmptyArrayIsRequiredError
  ParseAnyCharError
  UnreachableError
}

///|
pub impl Show for ParseError with output(self : ParseError, logger : &Logger) -> Unit {
  match self {
    ParseCharError(expected~) =>
      logger.write_string("Parse Error: expected '\{expected}'")
    ParseStringError(expected~) =>
      logger.write_string("Parse Error: expected \"\{expected}\"")
    ParseDigitError => logger.write_string("Parse Error: expected digit")
    NonEmptyArrayIsRequiredError =>
      logger.write_string(
        "Non empty array of parsers if required for choice combinator",
      )
    ParseAnyCharError => logger.write_string("Parse Error: expected any char")
    UnreachableError =>
      logger.write_string("Unreachable Error. This occurs by parsem's bug.")
  }
}

///|
pub type CList = @list.List[Char]

///|
pub type ParseResult[T] = Result[(T, CList), ParseError]

///|
pub struct Parser[T]((CList) -> ParseResult[T]) derive(Show)

///|
pub fn[T] Parser::new(f : (CList) -> ParseResult[T]) -> Parser[T] {
  Parser(f)
}

///|
trait Parsable {
  to_char_list(Self) -> CList
}

///|
pub impl Parsable for String with to_char_list(self : String) {
  @list.from_array(self.to_array())
}

///|
pub impl Parsable for CList with to_char_list(self : CList) { self }

///|
pub fn[S : Parsable, T] parse(parser : Parser[T], input : S) -> ParseResult[T] {
  (parser.0)(input.to_char_list())
}

///|
/// Matches one character.
/// Returns matched character.
pub fn char(expected : Char) -> Parser[Char] {
  return Parser(fn(input : CList) -> ParseResult[Char] {
    match input.head() {
      Some(c) =>
        if c == expected {
          Ok((c, input.unsafe_tail()))
        } else {
          Err(ParseCharError(expected~))
        }
      None => Err(ParseCharError(expected~))
    }
  })
}

///|
/// Matches one digit character.
/// Returns matched character.
pub fn digit() -> Parser[Char] {
  return Parser(fn(input : CList) -> ParseResult[Char] {
    match input.head() {
      Some(c) =>
        if is_digit(c) {
          Ok((c, input.unsafe_tail()))
        } else {
          Err(ParseDigitError)
        }
      None => Err(ParseDigitError)
    }
  })
}

///|
/// Matches one string.
/// Returns matched string.
pub fn string(expected : String) -> Parser[String] {
  return Parser(fn(input : CList) -> ParseResult[String] {
    let str = String::from_array(input.take(expected.length()).to_array())
    if str == expected {
      Ok((str, input.drop(expected.length())))
    } else {
      Err(ParseStringError(expected~))
    }
  })
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// Matches digitsstring.
/// Returns matched digit string automatically convert into specific number type by @strconv.
pub fn[T : @strconv.FromStr] digits() -> Parser[T] {
  return Parser(fn(input : CList) -> ParseResult[T] {
    let digits = String::from_array(input.take_while(is_digit).to_array())
    if digits.length() == 0 {
      return Err(ParseDigitError)
    }
    let parsed_number : Result[T, @strconv.StrConvError] =
      try? @strconv.from_str(digits)
    match parsed_number {
      Ok(number) => Ok((number, input.drop(digits.length())))
      Err(_) => Err(ParseDigitError)
    }
  })
}

///|
/// Just consumes any character
pub fn any_char() -> Parser[Char] {
  return Parser(fn(input : CList) -> ParseResult[Char] {
    if input.length() > 0 {
      Ok((input.head().unwrap(), input.unsafe_tail()))
    } else {
      Err(ParseAnyCharError)
    }
  })
}
