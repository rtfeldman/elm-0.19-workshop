port module Stylesheets exposing (..)

import Css.File exposing (..)
import ElmHubCss
import Html exposing (div)


port files : CssFileStructure -> Cmd msg


cssFiles : CssFileStructure
cssFiles =
    toFileStructure [ ( "style.css", compile [ ElmHubCss.css ] ) ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( (), files cssFiles )
        , view = \_ -> div [] []
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
