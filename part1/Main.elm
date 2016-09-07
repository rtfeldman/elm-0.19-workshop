module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


main =
    div [ class "content" ]
        [ header []
            [ -- TODO wrap this text in an <h1>
              text "ElmHub"
            , span
                [-- TODO give this span a class="tagline" attribute.
                 --
                 -- HINT: look at how our <div class="content"> does this above.
                ]
                [{- TODO put some text in here that says:
                    "Like GitHub, but for Elm things."
                 -}
                ]
            ]
        ]
