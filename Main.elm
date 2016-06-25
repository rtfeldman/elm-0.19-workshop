module Main exposing (..)

{-| THIS FILE IS NOT PART OF THE WORKSHOP! It is only to verify that you
have everything set up properly.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App
import Auth
import Http
import Task exposing (Task)
import Json.Decode exposing (Decoder)


main : Program Never
main =
    Html.App.program
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
    Auth.token
        |> (++) "https://api.github.com/search/repositories?q=test&access_token="
        |> Http.get (Json.Decode.succeed "")
        |> Task.perform ItFailed (\_ -> ItWorked)


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
    = ItWorked
    | ItFailed Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ItWorked ->
            ( { status = "You're all set!" }, Cmd.none )

        ItFailed err ->
            let
                status =
                    case err of
                        Http.Timeout ->
                            "Timed out trying to contact GitHub. Check your Internet connection?"

                        Http.NetworkError ->
                            "Network error. Check your Internet connection?"

                        Http.UnexpectedPayload msg ->
                            "Something is misconfigured: " ++ msg

                        Http.BadResponse code msg ->
                            case code of
                                401 ->
                                    "Auth.elm does not have a valid token. :( Try recreating Auth.elm by following the steps in the README under the section “Create a GitHub Personal Access Token”."

                                _ ->
                                    "GitHub's Search API returned an error: "
                                        ++ (toString code)
                                        ++ " "
                                        ++ msg
            in
                ( { status = status }, Cmd.none )
