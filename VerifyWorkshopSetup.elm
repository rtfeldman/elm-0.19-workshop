module VerifyWorkshopSetup exposing (main)

{- | Displays “You’re all set!” and a heart in the style of the Elm logo (created
      by Marco Perone, CC-BY-SA-4.0 - thanks for sharing it, Marco!)

   If this doesn't display, it means something needs to be fixed about your local
   setup, and you should ask the instructor for help!
-}

import Html exposing (Html, h1, img, section, text)
import Html.Attributes exposing (alt, src, style)


main : Html msg
main =
    section
        [ style
            [ ( "margin", "40px auto" )
            , ( "width", "960px" )
            , ( "text-align", "center" )
            ]
        ]
        [ h1
            [ style
                [ ( "margin", "40px auto" )
                , ( "font-family", "Helvetica, Arial, sans-serif" )
                , ( "font-size", "128px" )
                , ( "color", "rgb(90, 99, 120)" )
                ]
            ]
            [ text "You’re all set!" ]
        , img
            [ alt "Heart in the style of the Elm logo, by Marco Perone"
            , src "https://user-images.githubusercontent.com/1094080/39399444-a90f2746-4aeb-11e8-9bd6-4fe45e535921.png"
            , style
                [ ( "width", "368px" )
                , ( "height", "305px" )
                ]
            ]
            []
        ]
