module ElmHubCss exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)


-- Documentation:
-- http://package.elm-lang.org/packages/rtfeldman/elm-css/latest


css : Stylesheet
css =
    stylesheet
        [ -- TODO style hide-result
          --
          -- .hide-result {
          --   background-color: transparent;
          --   font-weight: bold;
          --   font-size: 18px;
          --   margin-left: 18px;
          --   border: 0px;
          --   cursor: pointer;
          -- }
          --
          --
          -- HINT: we use hover later on in the stylesheet...
          --
          -- .hide-result:hover {
          --   color: rgb(96, 181, 204);
          -- }
          (.) "content"
            [ width (px 960)
            , margin2 zero auto
            , padding (px 30)
            , fontFamilies [ "Helvetica", "Arial", "serif" ]
            ]
        , header
            [ position relative
            , padding2 (px 6) (px 12)
            , height (px 36)
            , backgroundColor (rgb 96 181 204)
            ]
        , h1
            [ color (hex "ffffff")
            , margin zero
            ]
        , (.) "tagline"
            [ color (hex "eeeeee")
            , position absolute
            , right (px 16)
            , top (px 12)
            , fontSize (px 24)
            , fontStyle italic
            ]
        , (.) "results"
            [ property "list-style-image" "url('http://img-cache.cdn.gaiaonline.com/76bd5c99d8f2236e9d3672510e933fdf/http://i278.photobucket.com/albums/kk81/d3m3nt3dpr3p/Tiny-Star-Icon.png')"
            , property "list-style-position" "inside"
            , padding zero
            ]
        , (.) "results"
            [ descendants
                [ li
                    [ fontSize (px 18)
                    , marginBottom (px 16)
                    ]
                ]
            ]
        , (.) "star-count"
            [ fontWeight bold
            , marginRight (px 16)
            ]
        , a
            [ color (rgb 96 181 204)
            , textDecoration none
            , hover
                [ textDecoration underline ]
            ]
        , (.) "search-query"
            [ padding (px 8)
            , fontSize (px 24)
            , marginBottom (px 18)
            , marginTop (px 36)
            ]
        , (.) "search-button"
            [ padding2 (px 8) (px 16)
            , fontSize (px 24)
            , color (hex "ffffff")
            , border3 (px 1) solid (hex "cccccc")
            , backgroundColor (rgb 96 181 204)
            , marginLeft (px 12)
            , hover
                [ color (rgb 96 181 204)
                , backgroundColor (hex "ffffff")
                ]
            ]
        , (.) "search-option"
            [ descendants
                [ selector "input[type=\"text\"]"
                    [ padding (px 5)
                    , boxSizing borderBox
                    , width (pct 90)
                    ]
                ]
            ]
        , each [ button, input ]
            [ focus [ outline none ]
            ]
        , (.) "search"
            [ after
                [ property "content" "\"\""
                , property "display" "table"
                , property "clear" "both"
                ]
            ]
        , (.) "error"
            [ backgroundColor (hex "FF9632")
            , padding (px 20)
            , boxSizing borderBox
            , overflowX auto
            , fontFamily monospace
            , fontSize (px 18)
            ]
        , (.) "top-label"
            [ display block
            , color (hex "555555")
            ]
        , th
            [ textAlign left
            , cursor pointer
            , hover [ color (rgb 96 181 204) ]
            ]
        , each
            [ th, td ]
            [ fontSize (px 18)
            , paddingRight (px 20)
            ]
        , (.) "stars-error"
            [ backgroundColor (hex "FF9632")
            , fontSize (px 16)
            , padding (px 10)
            , marginRight (px 24)
            , borderRadius (px 10)
            , marginTop (px 10)
            ]
        , (.) "search-input"
            [ display block
            , property "float" "left"
            , width (pct 42)
            ]
        , (.) "search-options"
            [ position relative
            , property "float" "right"
            , width (pct 58)
            , boxSizing borderBox
            , paddingTop (px 20)
            ]
        , (.) "search-option"
            [ display block
            , property "float" "left"
            , width (pct 30)
            , marginLeft (px 16)
            , boxSizing borderBox
            ]
        ]
