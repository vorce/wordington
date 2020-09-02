# Wordington

A way to find words (by default in Swedish) that matches both a pattern of known and unknown letters, and only containing a subset of letters.

Right now the implementation is basically meant to be used in a iex shell. However there's an online version you can play around with that uses this code: [**Ordington**](https://desolate-scrubland-88293.herokuapp.com/)

## Example

```elixir
pattern = ["g", "_", "_", "_", "_", "l"]
available_letters = ["d", "a", "g", "l", "i", "e", "n"]
Wordington.candidates(pattern, available_letters)
["genial"]
```

The underscore character (`_`) in a pattern is special and means any of the available letters is valid. See docs of the [`candidates/3`](lib/wordington.ex) function for options (to change word list for example).

## Use cases

Cheat at crossword puzzles (use the full alphabet as subset of available letters), or similar games.

## Word list

The included word list is from: http://runeberg.org/words/ ("Lars Aronssons svenska ordlista" `ss100.txt`) - thanks!

It has been converted to UTF-8. I don't remember exactly what command I used to do that, but it was from one of the replies in this SO thread: https://stackoverflow.com/questions/11316986/how-to-convert-iso8859-15-to-utf8
