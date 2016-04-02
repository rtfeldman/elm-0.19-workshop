module Main (..) where

{-| THIS FILE IS NOT PART OF THE WORKSHOP! It is only to verify that you
have everything set up properly.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Auth
import StartApp
import Http
import Task exposing (Task)
import Effects exposing (Effects)
import Json.Decode exposing (Decoder, (:=))
import Json.Encode
import Signal exposing (Address)


main : Signal Html
main =
  app.html


app : StartApp.App Model
app =
  StartApp.start
    { view = view
    , update = update
    , init = ( initialModel, Effects.task searchFeed )
    , inputs = []
    }


initialModel : Model
initialModel =
  { status = "Verifying setup..."
  }


type alias Model =
  { status : String }


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


searchFeed : Task x Action
searchFeed =
  let
    url =
      "https://api.github.com/search/repositories?q=test&access_token="
        ++ Auth.token
  in
    performAction
      (\_ -> ItWorked)
      (\err -> ItFailed err)
      (Http.get (Json.Decode.succeed "") url)


performAction : (a -> b) -> (y -> b) -> Task y a -> Task x b
performAction successToAction errorToAction task =
  let
    successTask =
      Task.map successToAction task
  in
    Task.onError successTask (\err -> Task.succeed (errorToAction err))


view : Address Action -> Model -> Html
view address model =
  div
    [ class "content" ]
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


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


type Action
  = ItWorked
  | ItFailed Http.Error


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    ItWorked ->
      ( { status = "You're all set!" }, Effects.none )

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
        ( { status = status }, Effects.none )
