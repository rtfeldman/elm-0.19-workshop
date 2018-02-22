module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, property, target)
import Html.Events exposing (..)
import Json.Starter as Json exposing (Json, Outcome(..), required)
import SampleResponse


type alias Model =
    { query : String
    , results : List SearchResult
    }


type alias SearchResult =
    { name : String
    , id : Int
    , stars : Int
    }


decodeSearchResult : Json -> Result String SearchResult
decodeSearchResult json =
    -- See https://developer.github.com/v3/search/#example
    --
    -- Look in SampleResponse.elm to see the exact JSON we'll be decoding!
    case
        Json.decodeObject json
            -- TODO insert the appropriate strings to decode the id and stars
            [ required [ "name" ]
            , required []
            , required []
            ]
    of
        [ String name {- TODO match the types with the other 2 `required` fields -} ] ->
            Ok
                { name = ""
                , id = 0
                , stars = 0
                }

        errors ->
            Err (Json.errorsToString errors)


decodeSearchResults : Json -> Result String (List SearchResult)
decodeSearchResults json =
    case
        Json.decodeObject json
            -- TODO specify the required field for the search result items
            -- based on https://developer.github.com/v3/search/#example
            --
            -- HINT: It's a field on the outermost object, and it holds an array.
            [ required [] ]
    of
        [ List searchResultsJson ] ->
            Json.decodeAll searchResultsJson decodeSearchResult

        errors ->
            Err (Json.errorsToString errors)


decodeResults : String -> List SearchResult
decodeResults rawJson =
    case decodeSearchResults (Json.fromString rawJson) of
        Ok searchResults ->
            searchResults

        _ ->
            -- If it failed, we'll return no search results for now.
            -- We could improve this by displaying an error to the user!
            []


initialModel : Model
initialModel =
    { query = "tutorial"
    , results = decodeResults SampleResponse.json
    }


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
        , button [ class "search-button" ] [ text "Search" ]
        , ul [ class "results" ]
            (List.map viewSearchResult model.results)
        ]


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
    = SetQuery String
    | DeleteById Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetQuery query ->
            { model | query = query }

        DeleteById idToHide ->
            let
                newResults =
                    List.filter (\{ id } -> id /= idToHide) model.results
            in
            { model | results = newResults }


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { view = view
        , update = update
        , model = initialModel
        }
