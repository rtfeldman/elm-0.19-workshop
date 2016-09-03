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
    -- TODO add tableState : Table.State to the Model
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    }


type Msg
    = Search
    | Visit String
    | SetQuery String
    | DeleteById Int
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError (Maybe String)
      -- TODO add a new constructor: SetTableState Table.State
    | DoNothing


initialQuery : String
initialQuery =
    "tutorial"


init : ( Model, Cmd Msg )
init =
    -- TODO initialize the Model's tableState to (Table.initialSort "Stars")
    ( { query = initialQuery
      , results = []
      , errorMessage = Nothing
      }
    , githubSearch (getQueryString initialQuery)
    )


view : Model -> Html Msg
view model =
    let
        currentTableState : Table.State
        currentTableState =
            -- TODO have this use the actual current table state
            Table.initialSort "Stars"
    in
        div [ class "home-container" ]
            [ input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
            , button [ class "search-button", onClick Search ] [ text "Search" ]
            , viewErrorMessage model.errorMessage
              -- TODO have this use model.results instead of []
            , Table.view tableConfig currentTableState []
            ]


tableConfig : Table.Config SearchResult Msg
tableConfig =
    Table.config
        { toId = .id >> toString
        , toMsg =
            -- TODO have the table use SetTableState for its toMsg
            (\tableState -> DoNothing)
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

        -- TODO add a new branch for SetTableState
        -- which records the new tableState in the Model.
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
