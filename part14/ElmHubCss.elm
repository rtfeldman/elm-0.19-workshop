module ElmHubCss exposing (..)

import Css exposing (..)


css : Stylesheet
css =
    stylesheet
        [ ((.) "content")
            [ width (px 960)
            , margin2 zero auto
            , padding (px 30)
            , fontFamilies [ "Helvetica", "Arial", "serif" ]
            ]
        ]
