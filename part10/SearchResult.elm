module SearchResult (..) where

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder, (:=))
import Json.Decode.Pipeline exposing (..)
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
  decode Model
    |> required "id" Json.Decode.int
    |> required "full_name" Json.Decode.string
    |> required "stargazers_count" Json.Decode.int


view : Address a -> Model -> Html
view address result =
  li
    []
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
