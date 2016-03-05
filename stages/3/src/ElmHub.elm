module ElmHub (..) where

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
    ("id" := Json.Decode.int)
    ("name" := Json.Decode.string)
    ("stargazers_count" := Json.Decode.int)


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
    []
    [ h1 [] [ text "ElmHub" ]
    , input [ onInput address SetQuery, defaultValue model.query ] []
    , button [ onClick address Search ] [ text "Search" ]
    , div
        [ class "results" ]
        (List.map viewSearchResult model.results)
    ]


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


viewSearchResult : SearchResult -> Html
viewSearchResult result =
  div
    []
    [ div [ class "star-count" ] [ text (toString result.stars) ]
    , div [] [ text result.name ]
    ]


type Action
  = Search
  | SetQuery String
  | HideById ResultId
  | SetResults (List SearchResult)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Search ->
      ( model, Effects.task (searchFeed (Debug.log "searching for" model.query)) )

    SetQuery query ->
      ( { model | query = query }, Effects.none )

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
