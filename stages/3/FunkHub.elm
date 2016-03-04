module FunkHub (..) where

import Html exposing (div, button, text)
import Html.Events exposing (onClick)
import StartApp.Simple as StartApp


main =
  StartApp.start { model = model, view = view, update = update }


model =
  0


view address model =
  div
    []
    [ button [ onClick address Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick address Increment ] [ text "+" ]
    ]


type Action
  = Increment
  | Decrement


update action model =
  case action of
    Increment ->
      model + 1

    Decrement ->
      model - 1
