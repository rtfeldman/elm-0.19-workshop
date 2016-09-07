module Main exposing (..)

import ElmHub exposing (..)
import Html.App as Html


main : Program Never
main =
    Html.program
        { view = view
        , update = update
        , init = ( initialModel, githubSearch (getQueryString initialModel.query) )
        , subscriptions = \_ -> githubResponse decodeResponse
        }
