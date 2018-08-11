module Article.Tag exposing (Tag, list, toString)

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



-- SERIALIZATION


decoder : Decoder Tag
decoder =
    Decode.map Tag Decode.string
