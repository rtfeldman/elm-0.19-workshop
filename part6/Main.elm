module Main exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Http
import Html.App
import Task exposing (Task)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


main : Program Never
main =
    Html.App.program
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

        -- Hint: responseDecoder may be useful here
        task =
            "TODO replace this String with a Task using http://package.elm-lang.org/packages/evancz/elm-http/3.0.0/Http#get"
    in
        -- TODO replace this Cmd.none with a call to Task.perform
        -- http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Task#perform
        --
        -- Hint: pass these to Task.perform, but in a different order than this!
        --
        -- task
        -- HandleSearchResponse
        -- HandleSearchError
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
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError Http.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            ( model, searchFeed model.query )

        HandleSearchResponse results ->
            ( { model | results = results }, Cmd.none )

        HandleSearchError error ->
            -- TODO if decoding failed, store the message in model.errorMessage
            --
            -- Hint 1: look for "decode" in the documentation for this union type:
            -- http://package.elm-lang.org/packages/evancz/elm-http/3.0.1/Http#Error
            --
            -- Hint 2: to check if this is working, break responseDecoder
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
