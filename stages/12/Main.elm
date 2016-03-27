module Main (..) where

import StartApp
import Component.ElmHub exposing (..)
import Effects exposing (Effects)
import Task exposing (Task)
import Html exposing (Html)


main : Signal Html
main =
  app.html


app : StartApp.App Model
app =
  StartApp.start
    { view = view
    , update = update
    , init = ( initialModel, Effects.task (searchFeed initialModel.query) )
    , inputs = []
    }


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks
