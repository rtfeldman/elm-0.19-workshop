module Stylesheets (..) where

import Css.File exposing (..)
import ElmHub.Css


port files : CssFileStructure
port files =
  toFileStructure
    [ ( "style.css", compile ElmHub.Css.css ) ]
