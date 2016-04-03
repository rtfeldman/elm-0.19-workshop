module SearchResult (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder, (:=))
import Signal exposing (Address)
import Dict exposing (Dict)


type alias ResultId =
  Int


type alias Model =
  { id : ResultId
  , name : String
  , stars : Int
  }


decoder : Decoder Model
decoder =
  Json.Decode.object3
    Model
    ("id" := Json.Decode.int)
    ("full_name" := Json.Decode.string)
    ("stargazers_count" := Json.Decode.int)


view : Address a -> (Int -> a) -> Model -> Html
view address delete result =
  li
    []
    [ span [ class "star-count" ] [ text (toString result.stars) ]
    , a
        [ href
            ("https://github.com/"
              ++ (Debug.log
                    "TODO we should not see this when typing in the search box!"
                    result.name
                 )
            )
        , target "_blank"
        ]
        [ text result.name ]
    , button
        [ class "hide-result", onClick address (delete result.id) ]
        [ text "X" ]
    ]
