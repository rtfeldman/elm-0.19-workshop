module ElmHub.Css (..) where

import Css exposing (..)


css =
  stylesheet
    [ ((.) "content")
        [ width (px 960)
        , margin2 zero auto
        , padding (px 30)
        , fontFamilies [ "Helvetica", "Arial", "serif" ]
        ]
    ]
