module Main exposing (..)

import ElmHub exposing (..)


main : Program Never
main =
    Html.App.program
        { view = view
        , update = update
        , init = ( initialModel, searchFeed initialModel.query )
        , inputs = []
        }
