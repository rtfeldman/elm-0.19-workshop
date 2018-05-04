module Data.Article.Tag
    exposing
        ( Tag
        , decoder
        , encode
        , listParser
        , toString
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Parser exposing ((|.), (|=), Parser, end, ignore, keep, oneOrMore, repeat, zeroOrMore)


type Tag
    = Tag String


toString : Tag -> String
toString (Tag str) =
    str


encode : Tag -> Value
encode (Tag str) =
    Encode.string str


decoder : Decoder Tag
decoder =
    Decode.map Tag Decode.string


listParser : Parser (List Tag)
listParser =
    Parser.succeed (List.map Tag)
        |. ignore zeroOrMore isWhitespace
        |= repeat zeroOrMore tag
        |. end



-- INTERNAL --


tag : Parser String
tag =
    keep oneOrMore (\char -> not (isWhitespace char))
        |. ignore zeroOrMore isWhitespace


isWhitespace : Char -> Bool
isWhitespace char =
    -- Treat hashtags and commas as effectively whitespace; ignore them.
    char == '#' || char == ',' || char == ' '
