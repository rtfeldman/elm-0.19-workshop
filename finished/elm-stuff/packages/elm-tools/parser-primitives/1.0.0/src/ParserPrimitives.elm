module ParserPrimitives exposing
  ( isSubString
  , isSubChar
  , findSubString
  )

{-| Low-level functions for creating parser combinator libraries.

@docs isSubString, isSubChar, findSubString
-}

import Native.ParserPrimitives



-- STRINGS


{-| When making a fast parser, you want to avoid allocation as much as
possible. That means you never want to mess with the source string, only
keep track of an offset into that string.

You use `isSubString` like this:

    isSubString "let" offset row col "let x = 4 in x"
        --==> ( newOffset, newRow, newCol )

You are looking for `"let"` at a given `offset`. On failure, the
`newOffset` is `-1`. On success, the `newOffset` is the new offset. With
our `"let"` example, it would be `offset + 3`.

You also provide the current `row` and `col` which do not align with
`offset` in a clean way. For example, when you see a `\n` you are at
`row = row + 1` and `col = 1`. Furthermore, some UTF16 characters are
two words wide, so even if there are no newlines, `offset` and `col`
may not be equal.
-}
isSubString : String -> Int -> Int -> Int -> String -> (Int, Int, Int)
isSubString =
  Native.ParserPrimitives.isSubString



-- CHARACTERS


{-| Again, when parsing, you want to allocate as little as possible.
So this function lets you say:

    isSubChar isSpace offset "this is the source string"
        --==> newOffset

The `(Char -> Bool)` argument is called a predicate.
The `newOffset` value can be a few different things:

  - `-1` means that the predicate failed
  - `-2` means the predicate succeeded with a `\n`
  - otherwise you will get `offset + 1` or `offset + 2`
    depending on whether the UTF16 character is one or two
    words wide.

It is better to use union types in general, but it is worth the
danger *within* parsing libraries to get the benefit *outside*.

So you can write a `chomp` function like this:

    chomp : (Char -> Bool) -> Int -> Int -> Int -> String -> (Int, Int, Int)
    chomp isGood offset row col source =
      let
        newOffset =
          Prim.isSubChar isGood offset source
      in
        -- no match
        if newOffset == -1 then
          (offset, row, col)

        -- newline match
        else if newOffset == -2 then
          chomp isGood (offset + 1) (row + 1) 1 source

        -- normal match
        else
          chomp isGood newOffset row (col + 1) source

Notice that `chomp` can be tail-call optimized, so this turns into a
`while` loop under the hood.
-}
isSubChar : (Char -> Bool) -> Int -> String -> Int
isSubChar =
  Native.ParserPrimitives.isSubChar



-- INDEX


{-| Find a substring after a given offset.

    findSubString before "42" offset row col "Is 42 the answer?"
        --==> (newOffset, newRow, newCol)

If `offset = 0` and `before = True` we would get `(3, 1, 4)`
If `offset = 0` and `before = False` we would get `(5, 1, 6)`

If `offset = 7` we would get `(-1, 1, 18)`
-}
findSubString : Bool -> String -> Int -> Int -> Int -> String -> (Int, Int, Int)
findSubString =
  Native.ParserPrimitives.findSubString
