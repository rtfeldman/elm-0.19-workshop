module FunkHub (..) where

import Html exposing (..)
import Html.Events exposing (onClick)
import StartApp.Simple as StartApp


main =
  StartApp.start { model = model, view = view, update = update }


model =
  0


view address model =
  div
    []
    [ h1 [] [ text "FunkHub" ]
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
