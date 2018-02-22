module Main exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, property, target)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , update = update
        , init = ( initialModel, searchFeed initialModel.query )
        , subscriptions = \_ -> Sub.none
        }


searchFeed : String -> Cmd Msg
searchFeed query =
    let
        url =
            "https://api.github.com/search/repositories?access_token="
                ++ Auth.token
                ++ "&q="
                ++ query
                ++ "+language:elm&sort=stars&order=desc"

        -- HINT: responseDecoder may be useful here.
        request =
            "TODO replace this String with a Request built using http://package.elm-lang.org/packages/elm-lang/http/latest/Http#get"
    in
    -- TODO replace this Cmd.none with a call to Http.send
    -- http://package.elm-lang.org/packages/elm-lang/http/latest/Http#send
    --
    -- HINT: request and HandleSearchResponse may be useful here.
    Cmd.none


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


viewErrorMessage : Maybe String -> Html Msg
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
    | HandleSearchResponse (Result Http.Error (List SearchResult))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, searchFeed model.query )

        HandleSearchResponse result ->
            case result of
                Ok results ->
                    ( { model | results = results }, Cmd.none )

                Err error ->
                    -- TODO if decoding failed, store the message in model.errorMessage
                    --
                    -- HINT 1: Remember, model.errorMessage is a Maybe String - so it
                    -- can only be set to either Nothing or (Just "some string here")
                    --
                    -- Hint 2: look for "decode" in the documentation for this union type:
                    -- http://package.elm-lang.org/packages/elm-lang/http/latest/Http#Error
                    --
                    -- Hint 3: to check if this is working, break responseDecoder
                    -- by changing "stargazers_count" to "description"
                    ( model, Cmd.none )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        DeleteById idToHide ->
            let
                newResults =
                    model.results
                        |> List.filter (\{ id } -> id /= idToHide)

                newModel =
                    { model | results = newResults }
            in
            ( newModel, Cmd.none )
