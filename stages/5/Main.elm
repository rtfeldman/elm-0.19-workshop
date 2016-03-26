module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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
    , init = ( initialModel, Effects.task (searchFeed initialModel.query) )
    , inputs = []
    }


port tasks : Signal (Task Effects.Never ())
port tasks =
  app.tasks


searchFeed : String -> Task x Action
searchFeed query =
  let
    -- See https://developer.github.com/v3/search/#example for how to customize!
    url =
      "https://api.github.com/search/repositories?q="
        ++ query
        ++ "+language:elm&sort=stars&order=desc"

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
  Json.Decode.object3
    SearchResult
    -- See https://developer.github.com/v3/search/#example
    ("TODO what field goes here?" := Json.Decode.int)
    ("TODO what field goes here?" := Json.Decode.string)
    ("TODO what field goes here?" := Json.Decode.int)


type alias Model =
  { query : String
  , results : List SearchResult
  }


type alias SearchResult =
  { id : ResultId
  , name : String
  , stars : Int
  }


type alias ResultId =
  Int


initialModel : Model
initialModel =
  { query = "tutorial"
  , results = []
  }


view : Address Action -> Model -> Html
view address model =
  div
    [ class "content" ]
    [ header
        []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
        ]
    , input [ class "search-query", onInput address SetQuery, defaultValue model.query ] []
    , button [ class "search-button" {- TODO on click, run a search -} ] [ text "Search" ]
    , ul
        [ class "results" ]
        (List.map (viewSearchResult address) model.results)
    ]


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


viewSearchResult : Address Action -> SearchResult -> Html
viewSearchResult address result =
  li
    []
    [ span [ class "star-count" ] [ text (toString result.stars) ]
    , a
        [ href ("https://github.com/" ++ result.name), target "_blank" ]
        [ text result.name ]
    , button
        [ class "hide-result", onClick address (DeleteById result.id) ]
        [ text "X" ]
    ]


type Action
  = Search
  | SetQuery String
  | DeleteById ResultId
  | SetResults (List SearchResult)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Search ->
      ( model, Effects.none {- TODO use searchFeed to run a search -} )

    SetQuery query ->
      ( { model | query = query }, Effects.none )

    SetResults results ->
      let
        newModel =
          { model | results = results }
      in
        ( newModel, Effects.none )

    DeleteById idToHide ->
      let
        newResults =
          List.filter (\{ id } -> id /= idToHide) model.results

        newModel =
          { model | results = newResults }
      in
        ( newModel, Effects.none )
