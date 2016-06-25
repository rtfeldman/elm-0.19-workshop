module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Auth
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Dict exposing (Dict)


getQueryUrl : String -> String
getQueryUrl query =
    -- See https://developer.github.com/v3/search/#example for how to customize!
    "https://api.github.com/search/repositories?access_token="
        ++ Auth.token
        ++ "&q="
        ++ query
        ++ "+language:elm&sort=stars&order=desc"


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    Json.Decode.at [ "items" ] (Json.Decode.list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int


type alias Model =
    { query : String
    , results : Dict ResultId SearchResult
    , errorMessage : Maybe String
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
        , ul [ class "results" ] (viewSearchResults model.results)
        ]


viewSearchResults : Dict ResultId SearchResult -> List (Html Msg)
viewSearchResults results =
    -- TODO sort by star count and render
    []


viewSearchResult : SearchResult -> Html Msg
viewSearchResult result =
    li []
        [ span [ class "star-count" ] [ text (toString result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ]
            [ text "X" ]
        ]


type Msg
    = Search
    | SetQuery String
    | DeleteById ResultId
    | SetResults (List SearchResult)
    | SetErrorMessage (Maybe String)
    | DoNothing


update : (String -> Cmd Msg) -> Msg -> Model -> ( Model, Cmd Msg )
update searchFeed msg model =
    case msg of
        Search ->
            ( model, searchFeed (getQueryUrl model.query) )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        SetResults results ->
            let
                resultsById : Dict ResultId SearchResult
                resultsById =
                    -- TODO convert results list into a Dict
                    Dict.empty
            in
                ( { model | results = resultsById }, Cmd.none )

        DeleteById id ->
            -- TODO delete the result with the given id
            ( model, Cmd.none )

        SetErrorMessage errorMessage ->
            ( { model | errorMessage = errorMessage }, Cmd.none )

        DoNothing ->
            ( model, Cmd.none )
