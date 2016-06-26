module Main exposing (..)

import ElmHub exposing (..)
import Html.App


main : Program Never
main =
    Html.App.program
        { view = view
        , update = update
        , init = ( initialModel, searchFeed initialModel.query )
        , subscriptions = \_ -> Sub.none
        }
