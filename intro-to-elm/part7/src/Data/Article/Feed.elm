module Data.Article.Feed exposing (Feed, decoder)

import Data.Article as Article exposing (Article)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)


type alias Feed =
    { articles : List (Article ())
    , articlesCount : Int
    }



-- SERIALIZATION --


decoder : Decoder Feed
decoder =
    let
        articlesDecoder =
            Decode.list Article.decoder
    in
    decode Feed
        {- TODO Replace this `hardcoded []` with a decoder that
           uses `articlesDecoder` to decode the list of articles we need.

           The JSON we receive will look something like this:

              {
                  "articlesCount": 3,
                  "articles":
                      [
                          {"username": "foo", "bio": null, "image": "", "following": false },
                          {"username": "bar", "bio": null, "image": "", "following": true },
                          {"username": "baz", "bio": null, "image": "", "following": false }
                      ]
              }

              Once this works, there's another TODO in src/Data/Article/Author.elm
        -}
        |> hardcoded []
        |> required "articlesCount" Decode.int
