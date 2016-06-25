module SearchResult exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


type alias ResultId =
    Int


type alias Model =
    { id : ResultId
    , name : String
    , stars : Int
    }


decoder : Decoder Model
decoder =
    decode Model
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int


view : Model -> Html a
view result =
    li []
        [ span [ class "star-count" ] [ text (toString result.stars) ]
        , a
            [ href ("https://github.com/" ++ result.name)
            , target "_blank"
            ]
            [ text result.name ]
        , button
            -- TODO onClick, send a delete action to the address
            [ class "hide-result" ]
            [ text "X" ]
        ]
