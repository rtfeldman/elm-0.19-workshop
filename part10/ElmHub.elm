module ElmHub exposing (..)

import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int
