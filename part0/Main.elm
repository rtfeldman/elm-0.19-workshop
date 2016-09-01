module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


elmHubHeader =
    header []
        [ -- TODO wrap the following text in an <h1>
          text "ElmHub"
        , span [ class "tagline" ]
            [{- TODO put some text in here that says:
                "Like GitHub, but for Elm things."
             -}
            ]
        ]


main =
    div [ class "content" ]
        [ -- TODO put the header here
          ul [ class "results" ] []
        ]
