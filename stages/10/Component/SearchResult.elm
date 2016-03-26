module Component.SearchResult (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import Effects exposing (Effects)


type alias Model =
  { id : Int
  , name : String
  , stars : Int
  , expanded : Bool
  }


type alias ResultId =
  Int


type Action
  = Expand
  | Collapse


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Expand ->
      ( { model | expanded = True }, Effects.none )

    Collapse ->
      ( { model | expanded = False }, Effects.none )


view : Address Action -> Model -> Html
view address model =
  li
    []
    <| if model.expanded then
        [ span [ class "star-count" ] [ text (toString model.stars) ]
        , a
            [ href ("https://github.com/" ++ model.name), target "_blank" ]
            [ text model.name ]
        , button
            [ class "hide-result", onClick address Collapse ]
            [ text "X" ]
        ]
       else
        [ button
            [ class "expand-result", onClick address Expand ]
            [ text "Show" ]
        ]
