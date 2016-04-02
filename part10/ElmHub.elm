module ElmHub (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Auth
import Task exposing (Task)
import Effects exposing (Effects)
import Json.Decode exposing (Decoder, (:=))
import Json.Encode
import Signal exposing (Address)
import Dict exposing (Dict)
import SearchResult


searchFeed : String -> Task x Action
searchFeed query =
  let
    -- See https://developer.github.com/v3/search/#example for how to customize!
    url =
      "https://api.github.com/search/repositories?access_token="
        ++ Auth.token
        ++ "&q="
        ++ query
        ++ "+language:elm&sort=stars&order=desc"

    task =
      Http.get responseDecoder url
        |> Task.map SetResults
  in
    Task.onError task (\_ -> Task.succeed (SetResults []))


responseDecoder : Decoder (List SearchResult.Model)
responseDecoder =
  "items" := Json.Decode.list SearchResult.decoder


type alias Model =
  { query : String
  , results : Dict SearchResult.ResultId SearchResult.Model
  }


initialModel : Model
initialModel =
  { query = "tutorial"
  , results = Dict.empty
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
    , button [ class "search-button", onClick address Search ] [ text "Search" ]
    , ul
        [ class "results" ]
        (viewSearchResults address model.results)
    ]


viewSearchResults : Address Action -> Dict SearchResult.ResultId SearchResult.Model -> List Html
viewSearchResults address results =
  results
    |> Dict.values
    |> List.sortBy (.stars >> negate)
    |> filterResults
    |> List.map (SearchResult.view address DeleteById)


filterResults : List SearchResult.Model -> List SearchResult.Model
filterResults results =
  -- TODO filter out repos with 0 stars
  -- using a case-expression rather than List.filter
  results


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


type Action
  = Search
  | SetQuery String
  | DeleteById SearchResult.ResultId
  | SetResults (List SearchResult.Model)


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Search ->
      ( model, Effects.task (searchFeed model.query) )

    SetQuery query ->
      ( { model | query = query }, Effects.none )

    SetResults results ->
      let
        resultsById : Dict SearchResult.ResultId SearchResult.Model
        resultsById =
          results
            |> List.map (\result -> ( result.id, result ))
            |> Dict.fromList
      in
        ( { model | results = resultsById }, Effects.none )

    DeleteById id ->
      let
        newModel =
          { model | results = Dict.remove id model.results }
      in
        ( newModel, Effects.none )
