# Parsem

Parser combinator for Moonbit

## Example

```moonbit
let result : @parsem.ParseResult[(Int, Int)] = @parsem.parse(
    @parsem.sequence(
      @parsem.string("add ").then(@parsem.digits()).precede(@parsem.char(' ')),
      @parsem.digits(),
    ),
    "add 10 20",
)
// => ParseResult(Ok(((10, 20), @list.of([]))))

let ((left, right), _) = result._.unwrap()
left + right
// => 30
```
