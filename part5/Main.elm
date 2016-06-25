module Main exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


main : Program Never
main =
    Html.App.beginnerProgram
        { view = view
        , update = update
        , model = initialModel
        }


sampleJson : String
sampleJson =
    """
    {
    "total_count": 40,
    "incomplete_results": false,
    "items": [
      {
        "id": 3081286,
        "name": "Tetris",
        "full_name": "dtrupenn/Tetris",
        "owner": {
          "login": "dtrupenn",
          "id": 872147,
          "avatar_url": "https://secure.gravatar.com/avatar/e7956084e75f239de85d3a31bc172ace?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png",
          "gravatar_id": "",
          "url": "https://api.github.com/users/dtrupenn",
          "received_events_url": "https://api.github.com/users/dtrupenn/received_events",
          "type": "User"
        },
        "private": false,
        "html_url": "https://github.com/dtrupenn/Tetris",
        "description": "A C implementation of Tetris using Pennsim through LC4",
        "fork": false,
        "url": "https://api.github.com/repos/dtrupenn/Tetris",
        "created_at": "2012-01-01T00:31:50Z",
        "updated_at": "2013-01-05T17:58:47Z",
        "pushed_at": "2012-01-01T00:37:02Z",
        "homepage": "",
        "size": 524,
        "stargazers_count": 1,
        "watchers_count": 1,
        "language": "Assembly",
        "forks_count": 0,
        "open_issues_count": 0,
        "master_branch": "master",
        "default_branch": "master",
        "score": 10.309712
      }
    ]
  }
  """


responseDecoder : Decoder (List SearchResult)
responseDecoder =
    Json.Decode.at [ "items" ] (Json.Decode.list searchResultDecoder)


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
    -- See https://developer.github.com/v3/search/#example
    -- and http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/latest
    -- TODO replace these calls to `hardcoded` with calls to `require`
    decode SearchResult
        |> hardcoded 0
        |> hardcoded ""
        |> hardcoded 0


type alias Model =
    { query : String
    , results : List SearchResult
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
    , results = decodeResults sampleJson
    }


decodeResults : String -> List SearchResult
decodeResults json =
    -- TODO use Json.Decode.decodeString to translate this into either:
    --
    -- * the search results, if decoding succeeded
    -- * an empty list if decoding failed
    --
    -- see http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Json-Decode#decodeString
    []


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
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
    | DeleteById ResultId
    | SetResults (List SearchResult)


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetQuery query ->
            { model | query = query }

        SetResults results ->
            let
                newModel =
                    { model | results = results }
            in
                newModel

        DeleteById idToHide ->
            let
                newResults =
                    List.filter (\{ id } -> id /= idToHide) model.results
            in
                { model | results = newResults }
