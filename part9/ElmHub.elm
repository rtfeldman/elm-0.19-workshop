port module ElmHub exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, property, target)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


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


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    decode SearchResult
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int


type alias Model =
    { query : String
    , results : List SearchResult
    , errorMessage : Maybe String
    }


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


initialModel : Model
initialModel =
    { query = "tutorial"
    , results = []
    , errorMessage = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, githubSearch (getQueryString initialModel.query) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    githubResponse decodeResponse


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
        , button [ class "search-button", onClick Search ] [ text "Search" ]
        , viewErrorMessage model.errorMessage
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewErrorMessage : Maybe String -> Html msg
viewErrorMessage errorMessage =
    case errorMessage of
        Just message ->
            div [ class "error" ] [ text message ]

        Nothing ->
            text ""


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
    | DeleteById Int
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError (Maybe String)
    | DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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


port githubSearch : String -> Cmd msg


port githubResponse : (Json.Decode.Value -> msg) -> Sub msg
