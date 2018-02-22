module Main exposing (..)

{-| THIS FILE IS NOT PART OF THE WORKSHOP! It is only to verify that you
have everything set up properly.
-}

import Auth
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (Decoder)


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , update = update
        , init = ( initialModel, searchFeed )
        , subscriptions = \_ -> Sub.none
        }


initialModel : Model
initialModel =
    { status = "Verifying setup..."
    }


type alias Model =
    { status : String }


searchFeed : Cmd Msg
searchFeed =
    let
        url =
            "https://api.github.com/search/repositories?q=test&access_token=" ++ Auth.token
    in
    Json.Decode.succeed ()
        |> Http.get url
        |> Http.send Response


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header [] [ h1 [] [ text "Elm Workshop" ] ]
        , div
            [ style
                [ ( "font-size", "48px" )
                , ( "text-align", "center" )
                , ( "padding", "48px" )
                ]
            ]
            [ text model.status ]
        ]


type Msg
    = Response (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Response (Ok ()) ->
            ( { status = "You're all set!" }, Cmd.none )

        Response (Err err) ->
            let
                status =
                    case err of
                        Http.Timeout ->
                            "Timed out trying to contact GitHub. Check your Internet connection?"

                        Http.NetworkError ->
                            "Network error. Check your Internet connection?"

                        Http.BadUrl url ->
                            "Invalid test URL: " ++ url

                        Http.BadPayload msg _ ->
                            "Something is misconfigured: " ++ msg

                        Http.BadStatus { status } ->
                            case status.code of
                                401 ->
                                    "Auth.elm does not have a valid token. :( Try recreating Auth.elm by following the steps in the README under the section “Create a GitHub Personal Access Token”."

                                _ ->
                                    "GitHub's Search API returned an error: "
                                        ++ toString status.code
                                        ++ " "
                                        ++ status.message
            in
            ( { status = status }, Cmd.none )
