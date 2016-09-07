module ElmHub exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, defaultValue, type', checked, placeholder, value)
import Html.Events exposing (..)
import Html.App as Html
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Search
import Tuple2


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
    { results : List SearchResult
    , errorMessage : Maybe String
    , search : Search.Model
    }


type alias SearchResult =
    { id : Int
    , name : String
    , stars : Int
    }


initialModel : Model
initialModel =
    { results = []
    , errorMessage = Nothing
    , search = Search.initialModel
    }


type Msg
    = SearchMsg Search.Msg
    | DeleteById Int
    | HandleSearchResponse (List SearchResult)
    | HandleSearchError (Maybe String)
    | DoNothing


init : ( Model, Cmd Msg )
init =
    -- TODO Incorporate Search.init
    --
    -- Search.init has the type ( Search.Model, Cmd Search.Msg )
    -- which we will convert to ( Model,        Cmd Msg )
    --
    -- Use Tuple2.mapEach to translate, by passing functions with these types:
    --
    -- (Search.Model -> Model)
    -- (Cmd Search.Msg -> Cmd Msg)
    --
    -- For reference:
    --
    -- mapEach : (a -> newA) -> (b -> newB) -> ( a, b ) -> ( newA, newB )
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchMsg searchMsg ->
            -- TODO Call Search.update passing the appropriate two arguments.
            --
            -- Then, since Search.update's return type is the same as Search.init,
            -- use the same process as we did with Search.init and init
            -- to translate between Search.update and update.
            --
            -- HINT: When you're done here, don't forget the TODO in Search.elm!
            Search.update searchMsg model.search
                |> Tuple2.mapEach (\search -> { model | search = search }) (Cmd.map SearchMsg)

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


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , Html.map SearchMsg (Search.view model.search)
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


decodeGithubResponse : Json.Decode.Value -> Msg
decodeGithubResponse value =
    case Json.Decode.decodeValue responseDecoder value of
        Ok results ->
            HandleSearchResponse results

        Err err ->
            HandleSearchError (Just err)
