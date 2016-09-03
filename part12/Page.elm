module Page exposing (..)

import Navigation
import UrlParser exposing (Parser, (</>), format, int, s, string)
import String


type Page
    = Home
    | Repository String String
    | NotFound


pageParser : Parser (Page -> a) a
pageParser =
    UrlParser.oneOf
        [ format Home (s "")
        , format Repository (s "repositories" </> string </> string)
        ]


parser : Navigation.Location -> Result String Page
parser location =
    location.pathname
        |> String.dropLeft 1
        |> UrlParser.parse identity pageParser
