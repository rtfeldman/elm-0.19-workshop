module ElmHub (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp
import Http
import Task exposing (Task)
import Effects exposing (Effects)
import Json.Decode exposing (Decoder, (:=))
import Signal exposing (Address)


main : Signal Html
main =
  app.html


app : StartApp.App Model
app =
  StartApp.start
    { view = view
    , update = update
    , init = ( initialModel, Effects.task (searchFeed "") )
    , inputs = []
    }


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


searchFeed : String -> Task x Action
searchFeed query =
  let
    url =
      "https://api.github.com/search/repositories?q=tutorial+language:elm&sort=stars&order=desc"

    task =
      Http.get responseDecoder url
        |> Task.map SetResults
  in
    Task.onError task (\_ -> Task.succeed (SetResults []))


responseDecoder : Decoder (List SearchResult)
responseDecoder =
  "items" := Json.Decode.list searchResultDecoder


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
  Json.Decode.object2
    SearchResult
    ("id" := Json.Decode.int)
    ("name" := Json.Decode.string)


type alias Model =
  { results : List SearchResult }


type alias SearchResult =
  { id : ResultId
  , name : String
  }


type alias ResultId =
  Int


initialModel : Model
initialModel =
  { results = [] }


view : Address Action -> Model -> Html
view address model =
  div
    []
    [ h1 [] [ text "ElmHub" ]
    , div
        [ class "results" ]
        (List.map viewSearchResult model.results)
    ]


viewSearchResult : SearchResult -> Html
viewSearchResult result =
  div [] [ text result.name ]


type Action
  = Search String
  | HideById ResultId
  | SetResults (List SearchResult)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Search query ->
      ( model, Effects.task (searchFeed query) )

    SetResults results ->
      let
        newModel =
          { model | results = results }
      in
        ( newModel, Effects.none )

    HideById idToHide ->
      let
        newResults =
          model.results
            |> List.filter (\{ id } -> id /= idToHide)

        newModel =
          { model | results = newResults }
      in
        ( newModel, Effects.none )
