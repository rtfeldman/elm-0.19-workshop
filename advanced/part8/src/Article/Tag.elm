module Article.Tag exposing (Tag, list, toString, validate)

import Api
import Http
import Json.Decode as Decode exposing (Decoder)



-- TYPES


type Tag
    = Tag String



-- TRANSFORM


toString : Tag -> String
toString (Tag slug) =
    slug



-- LIST


list : Http.Request (List Tag)
list =
    Decode.field "tags" (Decode.list decoder)
        |> Http.get (Api.url [ "tags" ])


validate : String -> List String -> Bool
validate str =
    String.split " " str
        |> List.map String.trim
        |> List.filter (not << String.isEmpty)
        |> (==)



-- SERIALIZATION


decoder : Decoder Tag
decoder =
    Decode.map Tag Decode.string
