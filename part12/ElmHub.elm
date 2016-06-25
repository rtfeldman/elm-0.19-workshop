module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import Http
import Auth
import Task exposing (Task)
import Json.Decode exposing (Decoder)
import Json.Encode
import Dict exposing (Dict)
import SearchResult exposing (ResultId)


searchFeed : String -> Task x Msg
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


viewSearchResults : Dict ResultId SearchResult.Model -> List Html
viewSearchResults results =
    results
        |> Dict.values
        |> List.sortBy (.stars >> negate)
        |> List.map (viewSearchResult address)


viewSearchResult : SearchResult.Model -> Html Msg
viewSearchResult result =
    SearchResult.view (Signal.forwardTo address (UpdateSearchResult result.id))
        result


type Msg
    = Search
    | SetQuery String
    | SetResults (List SearchResult.Model)
    | UpdateSearchResult ResultId SearchResult.Msg


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

        UpdateSearchResult id childMsg ->
            let
                updated =
                    model.results
                        |> Dict.get id
                        |> Maybe.map (SearchResult.update childMsg)
            in
                case updated of
                    Nothing ->
                        ( model, Cmd.none )

                    Just ( newChildModel, childEffects ) ->
                        let
                            effects =
                                Effects.map (UpdateSearchResult id) childEffects

                            newResults =
                                Dict.insert id newChildModel model.results
                        in
                            ( { model | results = newResults }, effects )
