module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Auth
import Task exposing (Task)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Json.Encode


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
    , results : List SearchResult
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
    , results = []
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
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewErrorMessage : Maybe String -> Html a
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
            ( { model | results = results }, Cmd.none )

        SetErrorMessage errorMessage ->
            ( { model | errorMessage = errorMessage }, Cmd.none )

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


decodeGithubResponse : Json.Encode.Value -> Msg
decodeGithubResponse value =
    -- TODO use Json.Decode.DecodeValue to decode the response into an Action.
    --
    -- Hint: look at ElmHub.elm, specifically the definition of Action and
    -- the deefinition of responseDecoder
    SetErrorMessage (Just "TODO decode the response!")
