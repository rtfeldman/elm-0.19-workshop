port module Main exposing (..)

{- | Displays “You’re all set!” and a heart in the style of the Elm logo (created
      by Marco Perone, CC-BY-SA-4.0 - thanks for sharing it, Marco!)

   If this doesn't display, it means something needs to be fixed about your local
   setup, and you should ask the instructor for help!
-}

import Browser
import Html exposing (Html, h1, img, section, text)
import Html.Attributes exposing (alt, src, style)
import Json.Decode exposing (Value)


port storeSession : Maybe String -> Cmd msg


port onSessionChange : (Value -> msg) -> Sub msg


main : Program () () ()
main =
    Browser.application
        { init = \_ _ _ -> ( (), Cmd.none )
        , onUrlChange = \_ -> ()
        , onUrlRequest = \_ -> ()
        , update =
            \() () ->
                if False then
                    ( (), storeSession Nothing )

                else
                    ( (), Cmd.none )
        , subscriptions = \() -> onSessionChange (\_ -> ())
        , view =
            \() ->
                { title = "Elm 0.19 workshop"
                , body =
                    [ section
                        [ style "margin" "40px auto"
                        , style "width" "960px"
                        , style "text-align" "center"
                        ]
                        [ h1
                            [ style "margin" "40px auto"
                            , style "font-family" "Helvetica, Arial, sans-serif"
                            , style "font-size" "128px"
                            , style "color" "rgb(90, 99, 120)"
                            ]
                            [ text "You’re all set!" ]
                        , img
                            [ alt "Heart in the style of the Elm logo, by Marco Perone"
                            , src "https://user-images.githubusercontent.com/1094080/39399444-a90f2746-4aeb-11e8-9bd6-4fe45e535921.png"
                            , style "width" "368px"
                            , style "height" "305px"
                            ]
                            []
                        ]
                    ]
                }
        }
