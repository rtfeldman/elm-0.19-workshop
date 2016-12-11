module Main exposing (main)

import ElmHub
import Html


main : Program Never ElmHub.Model ElmHub.Msg
main =
    Html.program
        { view = ElmHub.view
        , update = ElmHub.update
        , init = ElmHub.init
        , subscriptions = ElmHub.subscriptions
        }
