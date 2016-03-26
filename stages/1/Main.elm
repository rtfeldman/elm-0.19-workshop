module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)


model =
  { result =
      { id = 1
      , name = "TheSeamau5/elm-checkerboardgrid-tutorial"
      , stars = 66
      }
  }


view model =
  div
    [ class "content" ]
    [ header
        []
        [ -- TODO add the equivalent of <h1>ElmHub</h1> right before the tagline
          span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
        ]
    , ul
        [ class "results" ]
        [ li
            []
            [ span [ class "star-count" ] [{- TODO display the number of stars -}]
              -- TODO use the model to put a link here that points to
              -- https://github.com/TheSeamau5/elm-checkerboardgrid-tutorial
            ]
        ]
    ]


main =
  view model
