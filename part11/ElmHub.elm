module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App
import Http
import Auth
import Task exposing (Task)
import Json.Decode exposing (Decoder)
import Dict exposing (Dict)
import SearchResult exposing (ResultId)


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
    Json.Decode.at [ "items" ] (Json.Decode.list SearchResult.decoder)


type alias Model =
    { query : String
    , results : Dict ResultId SearchResult.Model
    , errorMessage : Maybe String
    }


initialModel : Model
initialModel =
    { query = "tutorial"
    , results = Dict.empty
    , errorMessage = Nothing
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
        , viewErrorMessage model.errorMessage
        , ul [ class "results" ] (viewSearchResults model.results)
        ]


viewErrorMessage : Maybe String -> Html a
viewErrorMessage errorMessage =
    case errorMessage of
        Just message ->
            div [ class "error" ] [ text message ]

        Nothing ->
            text ""


viewSearchResults : Dict ResultId SearchResult.Model -> List (Html Msg)
viewSearchResults results =
    results
        |> Dict.values
        |> List.sortBy (.stars >> negate)
        |> filterResults
        |> List.map viewSearchResult


filterResults : List SearchResult.Model -> List SearchResult.Model
filterResults results =
    -- TODO filter out repos with 0 stars
    -- using a case-expression rather than List.filter
    results


viewSearchResult : SearchResult.Model -> Html Msg
viewSearchResult result =
    result
        |> SearchResult.view
        |> Html.App.map (UpdateSearchResult result.id)


type Msg
    = Search
    | SetQuery String
    | UpdateSearchResult ResultId SearchResult.Msg
    | HandleSearchResponse (List SearchResult.Model)
    | HandleSearchError Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            model ! [ searchFeed model.query ]

        SetQuery query ->
            { model | query = query, errorMessage = Nothing } ! []

        HandleSearchError error ->
            case error of
                Http.UnexpectedPayload str ->
                    { model | errorMessage = Just str } ! []

                _ ->
                    { model | errorMessage = Just "Error loading search results" } ! []

        HandleSearchResponse results ->
            let
                resultsById : Dict ResultId SearchResult.Model
                resultsById =
                    results
                        |> List.map (\result -> ( result.id, result ))
                        |> Dict.fromList
            in
                { model | results = resultsById } ! []

        UpdateSearchResult id childMsg ->
            case Dict.get id model.results of
                Nothing ->
                    model ! []

                Just childModel ->
                    let
                        ( newChildModel, childCmd ) =
                            SearchResult.update childMsg childModel

                        cmd =
                            Cmd.map (UpdateSearchResult id) childCmd

                        newResults =
                            Dict.insert id newChildModel model.results
                    in
                        { model | results = newResults } ! [ cmd ]
