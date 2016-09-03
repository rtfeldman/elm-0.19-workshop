module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


elmHubHeader =
    header []
        [ -- TODO wrap this text in an <h1>
          text "ElmHub"
        , span [ class "tagline" ]
            [{- TODO put some text in here that says:
                "Like GitHub, but for Elm things."
             -}
            ]
        ]


main =
    div [ class "content" ]
        [ -- TODO Add elmHubHeader here.
          --
          -- HINT: You'll need a comma!
          ul [ class "results" ] []
        ]
