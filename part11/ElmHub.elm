module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Auth
import Task exposing (Task)
import Json.Decode exposing (Decoder)
import Json.Encode
import Dict exposing (Dict)
import SearchResult


searchFeed : String -> Cmd Msg
searchFeed query =
    let
        url =
            "https://api.github.com/search/repositories?access_token="
                ++ Auth.token
                ++ "&q="
                ++ query
                ++ "+language:elm&sort=stars&order=desc"
    in
        Task.perform HandleSearchError HandleSearchResponse (Http.get responseDecoder url)


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


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
            ]
        , input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
        , button [ class "search-button", onClick Search ] [ text "Search" ]
        , ul [ class "results" ] (viewSearchResults model.results)
        ]


viewSearchResults : Dict SearchResult.ResultId SearchResult.Model -> List (Html a)
viewSearchResults results =
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


type Msg
    = Search
    | SetQuery String
    | DeleteById SearchResult.ResultId
    | SetResults (List SearchResult.Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, searchFeed model.query )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        SetResults results ->
            let
                resultsById : Dict SearchResult.ResultId SearchResult.Model
                resultsById =
                    results
                        |> List.map (\result -> ( result.id, result ))
                        |> Dict.fromList
            in
                ( { model | results = resultsById }, Cmd.none )

        DeleteById id ->
            let
                newModel =
                    { model | results = Dict.remove id model.results }
            in
                ( newModel, Cmd.none )
