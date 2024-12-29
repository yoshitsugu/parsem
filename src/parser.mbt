///|
type! ParseError {
  ParseCharError(expected~ : Char)
  ParseStringError(expected~ : String)
  ParseDigitError
  NonEmptyArrayIsRequiredError
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
    UnreachableError =>
      logger.write_string("Unreachable Error. This occurs by parsem's bug.")
  }
}

///|
pub(readonly) type ParseResult[T] Result[(T, @immut/list.T[Char]), ParseError] derive (
  Show,
)

///|
pub(readonly) type Parser[T] (@immut/list.T[Char]) -> ParseResult[T] derive(Show)

///|
typealias CList = @immut/list.T[Char]

///|
trait Parsable {
  to_char_list(Self) -> CList
}

///|
pub impl Parsable for String with to_char_list(self : String) {
  @immut/list.from_array(self.to_array())
}

///|
pub impl Parsable for CList with to_char_list(self : CList) { self }

///|
pub fn parse[S : Parsable, T](parser : Parser[T], input : S) -> ParseResult[T] {
  (parser._)(input.to_char_list())
}

///|
/// Matches one character.
/// Returns matched character.
pub fn char(expected : Char) -> Parser[Char] {
  return Parser(fn(input : CList) -> ParseResult[Char] {
    match input.head() {
      Some(c) =>
        if c == expected {
          Ok((c, input.tail()))
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
          Ok((c, input.tail()))
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
    let str = @string.from_array(input.take(expected.length()).to_array())
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
pub fn digits[T : @strconv.FromStr]() -> Parser[T] {
  return Parser(fn(input : CList) -> ParseResult[T] {
    let digits = @string.from_array(input.take_while(is_digit).to_array())
    if digits.length() == 0 {
      return Err(ParseDigitError)
    }
    let parsed_number : Result[T, @strconv.StrConvError] = @strconv.parse?(
      digits,
    )
    match parsed_number {
      Ok(number) => Ok((number, input.drop(digits.length())))
      Err(_) => Err(ParseDigitError)
    }
  })
}
