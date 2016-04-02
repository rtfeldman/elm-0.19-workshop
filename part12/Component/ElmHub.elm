module Component.ElmHub (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import Http
import Task exposing (Task)
import Effects exposing (Effects)
import Json.Decode exposing (Decoder, (:=))
import Json.Encode
import Signal exposing (Address)
import Component.SearchResult exposing (ResultId)


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


responseDecoder : Decoder (List Component.SearchResult.Model)
responseDecoder =
  "items" := Json.Decode.list searchResultDecoder


searchResultDecoder : Decoder Component.SearchResult.Model
searchResultDecoder =
  Json.Decode.object4
    Component.SearchResult.Model
    ("id" := Json.Decode.int)
    ("full_name" := Json.Decode.string)
    ("stargazers_count" := Json.Decode.int)
    (Json.Decode.succeed True)


type alias Model =
  { query : String
  , results : List Component.SearchResult.Model
  }


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
    , button [ class "search-button", onClick address Search ] [ text "Search" ]
    , ul
        [ class "results" ]
        (viewSearchResults address model.results)
    ]


viewSearchResults : Address Action -> List Component.SearchResult.Model -> List Html
viewSearchResults address results =
  results
    |> filterResults
    |> List.map (lazy2 viewSearchResult address)


filterResults : List Component.SearchResult.Model -> List Component.SearchResult.Model
filterResults results =
  case results of
    [] ->
      []

    first :: rest ->
      if first.stars > 0 then
        first :: (filterResults rest)
      else
        filterResults rest


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


viewSearchResult : Address Action -> Component.SearchResult.Model -> Html
viewSearchResult address result =
  Component.SearchResult.view
    (Signal.forwardTo address (UpdateSearchResult result.id))
    (Debug.log "rendering result..." result)


type Action
  = Search
  | SetQuery String
  | SetResults (List Component.SearchResult.Model)
  | UpdateSearchResult ResultId Component.SearchResult.Action


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    Search ->
      ( model, Effects.task (searchFeed model.query) )

    SetQuery query ->
      ( { model | query = query }, Effects.none )

    SetResults results ->
      let
        newModel =
          { model | results = results }
      in
        ( newModel, Effects.none )

    UpdateSearchResult id childAction ->
      let
        updateResult childModel =
          if childModel.id == id then
            let
              ( newChildModel, childEffects ) =
                Component.SearchResult.update childAction childModel
            in
              ( newChildModel
              , Effects.map (UpdateSearchResult id) childEffects
              )
          else
            ( childModel, Effects.none )

        ( newResults, effects ) =
          model.results
            |> List.map updateResult
            |> List.unzip

        newModel =
          { model | results = newResults }
      in
        ( newModel, Effects.batch effects )
