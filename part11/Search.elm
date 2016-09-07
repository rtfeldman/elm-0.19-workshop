port module Search exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, defaultValue, type', checked, placeholder, value)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder)
import Auth
import String


port githubSearch : String -> Cmd msg


type alias Model =
    { query : String
    , sort : String
    , ascending : Bool
    , searchInDescription : Bool
    , userFilter : String
    }


type Msg
    = SetQuery String
    | SetSort String
    | SetAscending Bool
    | SetSearchInDescription Bool
    | SetUserFilter String
    | Search


init : ( Model, Cmd Msg )
init =
    ( initialModel, githubSearch (getQueryString initialModel) )


initialModel : Model
initialModel =
    { query = "tutorial"
    , sort = "stars"
    , ascending = False
    , searchInDescription = True
    , userFilter = ""
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Search ->
            -- TODO instead of Cmd.none, run this:
            -- githubSearch (getQueryString model)
            ( model, Cmd.none )

        SetQuery query ->
            ( { model | query = query }, Cmd.none )

        SetSort sort ->
            ( { model | sort = sort }, Cmd.none )

        SetAscending ascending ->
            ( { model | ascending = ascending }, Cmd.none )

        SetSearchInDescription searchInDescription ->
            ( { model | searchInDescription = searchInDescription }, Cmd.none )

        SetUserFilter userFilter ->
            ( { model | userFilter = userFilter }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "search" ]
        [ div [ class "search-options" ]
            [ div [ class "search-option" ]
                [ label [ class "top-label" ] [ text "Sort by" ]
                , select [ onChange SetSort, value model.sort ]
                    [ option [ value "stars" ] [ text "Stars" ]
                    , option [ value "forks" ] [ text "Forks" ]
                    , option [ value "updated" ] [ text "Updated" ]
                    ]
                ]
            , div [ class "search-option" ]
                [ label [ class "top-label" ] [ text "Owned by" ]
                , input
                    [ type' "text"
                    , placeholder "Enter a username"
                    , defaultValue model.userFilter
                    , onInput SetUserFilter
                    ]
                    []
                ]
            , label [ class "search-option" ]
                [ input [ type' "checkbox", checked model.ascending, onCheck SetAscending ] []
                , text "Sort ascending"
                ]
            , label [ class "search-option" ]
                [ input [ type' "checkbox", checked model.searchInDescription, onCheck SetSearchInDescription ] []
                , text "Search in description"
                ]
            ]
        , div [ class "search-input" ]
            [ input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
            , button [ class "search-button", onClick Search ] [ text "Search" ]
            ]
        ]


onChange : (String -> msg) -> Attribute msg
onChange toMsg =
    on "change" (Json.Decode.map toMsg Html.Events.targetValue)


getQueryString : Model -> String
getQueryString model =
    -- See https://developer.github.com/v3/search/#example for how to customize!
    "access_token="
        ++ Auth.token
        ++ "&q="
        ++ model.query
        ++ (if model.searchInDescription then
                "+in:name,description"
            else
                "+in:name"
           )
        ++ "+language:elm"
        ++ (if String.isEmpty model.userFilter then
                ""
            else
                "+user:" ++ model.userFilter
           )
        ++ "&sort="
        ++ model.sort
        ++ "&order="
        ++ (if model.ascending then
                "asc"
            else
                "desc"
           )
