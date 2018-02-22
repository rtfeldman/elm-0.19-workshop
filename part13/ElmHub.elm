port module ElmHub exposing (..)

import Auth
import Html exposing (..)
import Html.Attributes exposing (checked, class, defaultValue, href, placeholder, target, type_, value)
import Html.Events exposing (..)
import Html.Lazy exposing (lazy, lazy3)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import String
import Table


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
    , options : SearchOptions
    , tableState : Table.State
    }


type alias SearchOptions =
    { minStars : Int
    , minStarsError : Maybe String
    , searchIn : String
    , userFilter : String
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
    , options =
        { minStars = 0
        , minStarsError = Nothing
        , searchIn = "name"
        , userFilter = ""
        }
    , tableState = Table.initialSort "Stars"
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, githubSearch (getQueryString initialModel) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    githubResponse decodeResponse


viewOptions : SearchOptions -> Html OptionsMsg
viewOptions opts =
    div [ class "search-options" ]
        [ div [ class "search-option" ]
            [ label [ class "top-label" ] [ text "Search in" ]
            , select [ onChange SetSearchIn, value opts.searchIn ]
                [ option [ value "name" ] [ text "Name" ]
                , option [ value "description" ] [ text "Description" ]
                , option [ value "name,description" ] [ text "Name and Description" ]
                ]
            ]
        , div [ class "search-option" ]
            [ label [ class "top-label" ] [ text "Owned by" ]
            , input
                [ type_ "text"
                , placeholder "Enter a username"
                , defaultValue (Debug.log "username" opts.userFilter)
                , onInput SetUserFilter
                ]
                []
            ]
        , div [ class "search-option" ]
            [ label [ class "top-label" ] [ text "Minimum Stars" ]
            , input
                [ type_ "text"
                , onBlurWithTargetValue SetMinStars
                , defaultValue (toString opts.minStars)
                ]
                []
            , viewMinStarsError opts.minStarsError
            ]
        ]


viewMinStarsError : Maybe String -> Html msg
viewMinStarsError message =
    case message of
        Nothing ->
            text " "

        Just errorMessage ->
            div [ class "stars-error" ] [ text errorMessage ]


type Msg
    = Search
    | Options OptionsMsg
    | SetQuery String
    | DeleteById Int
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError (Maybe String)
    | SetTableState Table.State
    | DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Options optionsMsg ->
            ( { model | options = updateOptions optionsMsg model.options }, Cmd.none )

        Search ->
            ( model, githubSearch (getQueryString model) )

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

        SetTableState tableState ->
            ( { model | tableState = tableState }, Cmd.none )

        DoNothing ->
            ( model, Cmd.none )


onBlurWithTargetValue : (String -> msg) -> Attribute msg
onBlurWithTargetValue toMsg =
    on "blur" (Json.Decode.map toMsg targetValue)


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


updateOptions : OptionsMsg -> SearchOptions -> SearchOptions
updateOptions optionsMsg options =
    case optionsMsg of
        SetMinStars minStarsStr ->
            case String.toInt minStarsStr of
                Ok minStars ->
                    { options | minStars = minStars, minStarsError = Nothing }

                Err _ ->
                    { options
                        | minStarsError =
                            Just "Must be an integer!"
                    }

        SetSearchIn searchIn ->
            { options | searchIn = searchIn }

        SetUserFilter userFilter ->
            { options | userFilter = userFilter }


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , div [ class "search" ]
            [ Html.map Options (lazy viewOptions model.options)
            , div [ class "search-input" ]
                [ input [ class "search-query", onInput SetQuery, defaultValue model.query ] []
                , button [ class "search-button", onClick Search ] [ text "Search" ]
                ]
            ]
        , viewErrorMessage model.errorMessage
        , lazy3 Table.view tableConfig model.tableState model.results
        ]


viewErrorMessage : Maybe String -> Html msg
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
        [ a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button [ class "hide-result", onClick (DeleteById result.id) ]
            [ text "X" ]
        ]


type OptionsMsg
    = SetMinStars String
    | SetSearchIn String
    | SetUserFilter String


decodeGithubResponse : Json.Decode.Value -> Msg
decodeGithubResponse value =
    case Json.Decode.decodeValue responseDecoder value of
        Ok results ->
            HandleSearchResponse results

        Err err ->
            HandleSearchError (Just err)


onChange : (String -> msg) -> Attribute msg
onChange toMsg =
    on "change" (Json.Decode.map toMsg Html.Events.targetValue)


decodeResponse : Json.Decode.Value -> Msg
decodeResponse json =
    case Json.Decode.decodeValue responseDecoder json of
        Err err ->
            HandleSearchError (Just err)

        Ok results ->
            HandleSearchResponse results


port githubSearch : String -> Cmd msg


port githubResponse : (Json.Decode.Value -> msg) -> Sub msg


getQueryString : Model -> String
getQueryString model =
    -- See https://developer.github.com/v3/search/#example for how to customize!
    "access_token="
        ++ Auth.token
        ++ "&q="
        ++ model.query
        ++ "+in:"
        ++ model.options.searchIn
        ++ "+stars:>="
        ++ toString model.options.minStars
        ++ "+language:elm"
        ++ (if String.isEmpty model.options.userFilter then
                ""
            else
                "+user:" ++ model.options.userFilter
           )
