module Main exposing (main)

import ElmHub
import Html.App as Html


main : Program Never
main =
    Html.program
        { view = ElmHub.view
        , update = ElmHub.update
        , init = ElmHub.init
        , subscriptions = ElmHub.subscriptions
        }
