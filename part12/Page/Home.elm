port module Page.Home exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Auth
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Navigation
import Table


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int


getQueryString : String -> String
getQueryString query =
    -- See https://developer.github.com/v3/search/#example for how to customize!
    "access_token="
        ++ Auth.token
        ++ "&q="
        ++ query
        ++ "+language:elm&sort=stars&order=desc"


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    Json.Decode.at [ "items" ] (Json.Decode.list searchResultDecoder)


type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    , tableState : Table.State
    }


initialQuery : String
initialQuery =
    "tutorial"


init : ( Model, Cmd Msg )
init =
    ( { query = initialQuery
      , results = []
      , errorMessage = Nothing
      , tableState = Table.initialSort "Stars"
      }
    , githubSearch (getQueryString initialQuery)
    )


view : Model -> Html Msg
view model =
    div [ class "home-container" ]
        [ input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
        , button [ class "search-button", onClick Search ] [ text "Search" ]
        , viewErrorMessage model.errorMessage
        , Table.view tableConfig model.tableState model.results
        ]


tableConfig : Table.Config SearchResult Msg
tableConfig =
    Table.config
        { toId = .id >> toString
        , toMsg = SetTableState
        , columns = [ starsColumn, nameColumn ]
        }


starsColumn : Table.Column SearchResult Msg
starsColumn =
    Table.veryCustomColumn
        { name = "Stars"
        , viewData = viewStars
        , sorter = Table.increasingOrDecreasingBy (negate << .stars)
        }


nameColumn : Table.Column SearchResult Msg
nameColumn =
    Table.veryCustomColumn
        { name = "Name"
        , viewData = viewSearchResult
        , sorter = Table.increasingOrDecreasingBy .name
        }


viewErrorMessage : Maybe String -> Html a
viewErrorMessage errorMessage =
    case errorMessage of
        Just message ->
            div [ class "error" ] [ text message ]

        Nothing ->
            text ""


viewStars : SearchResult -> Table.HtmlDetails Msg
viewStars result =
    Table.HtmlDetails []
        [ span [ class "star-count" ] [ text (toString result.stars) ] ]


viewSearchResult : SearchResult -> Table.HtmlDetails Msg
viewSearchResult result =
    Table.HtmlDetails []
        [ a [ onClick (Visit ("/repositories/" ++ result.name)) ] [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ]
            [ text "X" ]
        ]


type Msg
    = Search
    | Visit String
    | SetQuery String
    | DeleteById Int
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError (Maybe String)
    | SetTableState Table.State
    | DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Visit url ->
            ( model, Navigation.newUrl url )

        Search ->
            ( model, githubSearch (getQueryString model.query) )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        HandleSearchResponse results ->
            ( { model | results = results }, Cmd.none )

        HandleSearchError error ->
            ( { model | errorMessage = error }, Cmd.none )

        DeleteById idToHide ->
            let
                newResults =
                    model.results
                        |> List.filter (\{ id } -> id /= idToHide)

                newModel =
                    { model | results = newResults }
            in
                ( newModel, Cmd.none )

        SetTableState newState ->
            ( { model | tableState = newState }, Cmd.none )

        DoNothing ->
            ( model, Cmd.none )


decodeGithubResponse : Json.Decode.Value -> Msg
decodeGithubResponse value =
    case Json.Decode.decodeValue responseDecoder value of
        Ok results ->
            HandleSearchResponse results

        Err err ->
            HandleSearchError (Just err)


decodeResponse : Json.Decode.Value -> Msg
decodeResponse json =
    case Json.Decode.decodeValue responseDecoder json of
        Err err ->
            HandleSearchError (Just err)

        Ok results ->
            HandleSearchResponse results


subscriptions : Model -> Sub Msg
subscriptions _ =
    githubResponse decodeResponse


port githubSearch : String -> Cmd msg


port githubResponse : (Json.Decode.Value -> msg) -> Sub msg
