module Stylesheets (..) where

import Css.File exposing (..)
import ElmHub


port files : CssFileStructure
port files =
  toFileStructure
    [ ( "style.css", compile ElmHub.css ) ]
