module Main exposing (..)

import ElmHub exposing (..)
import Html.App as Html


main : Program Never
main =
    Html.program
        { view = view
        , update = update
        , init = ( initialModel, searchFeed initialModel.query )
        , subscriptions = \_ -> Sub.none
        }
