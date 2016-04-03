module ElmHub (..) where

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property)
import Html.Events exposing (..)
import Http
import Auth
import Task exposing (Task)
import Effects exposing (Effects)
import Json.Decode exposing (Decoder, (:=))
import Json.Decode.Pipeline exposing (..)
import Json.Encode
import Signal exposing (Address)


searchFeed : Address String -> String -> Effects Action
searchFeed address query =
  let
    -- See https://developer.github.com/v3/search/#example for how to customize!
    url =
      "https://api.github.com/search/repositories?access_token="
        ++ Auth.token
        ++ "&q="
        ++ query
        ++ "+language:elm&sort=stars&order=desc"

    -- These only talk to JavaScript ports now. They never result in Actions
    -- actually do any actions themselves.
    task =
      performAction
        (\_ -> DoNothing)
        (\_ -> DoNothing)
        (Signal.send address query)
  in
    Effects.task task


responseDecoder : Decoder (List SearchResult)
responseDecoder =
  "items" := Json.Decode.list searchResultDecoder


searchResultDecoder : Decoder SearchResult
searchResultDecoder =
  decode SearchResult
    |> required "id" Json.Decode.int
    |> required "full_name" Json.Decode.string
    |> required "stargazers_count" Json.Decode.int


{-| Note: this will be a standard function in the next release of Elm.

Example:


type Action =
  HandleResponse String | HandleError Http.Error


performAction
  (\responseString -> HandleResponse responseString)
  (\httpError -> HandleError httpError)
  (Http.getString "https://google.com?q=something")

-}
performAction : (a -> b) -> (y -> b) -> Task y a -> Task x b
performAction successToAction errorToAction task =
  let
    successTask =
      Task.map successToAction task
  in
    Task.onError successTask (\err -> Task.succeed (errorToAction err))


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


view : Address Action -> Model -> Html
view address model =
  div
    [ class "content" ]
    [ header
        []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
        ]
    , input [ class "search-query", onInput address SetQuery, defaultValue model.query ] []
    , button [ class "search-button", onClick address Search ] [ text "Search" ]
    , viewErrorMessage model.errorMessage
    , ul
        [ class "results" ]
        (List.map (viewSearchResult address) model.results)
    ]


viewErrorMessage : Maybe String -> Html
viewErrorMessage errorMessage =
  case errorMessage of
    Just message ->
      div [ class "error" ] [ text message ]

    Nothing ->
      text ""


onInput address wrap =
  on "input" targetValue (\val -> Signal.message address (wrap val))


defaultValue str =
  property "defaultValue" (Json.Encode.string str)


viewSearchResult : Address Action -> SearchResult -> Html
viewSearchResult address result =
  li
    []
    [ span [ class "star-count" ] [ text (toString result.stars) ]
    , a
        [ href ("https://github.com/" ++ result.name), target "_blank" ]
        [ text result.name ]
    , button
        [ class "hide-result", onClick address (DeleteById result.id) ]
        [ text "X" ]
    ]


type Action
  = Search
  | SetQuery String
  | DeleteById ResultId
  | SetResults (List SearchResult)
  | SetErrorMessage (Maybe String)
  | DoNothing


update : Address String -> Action -> Model -> ( Model, Effects Action )
update searchAddress action model =
  case action of
    Search ->
      ( model, searchFeed searchAddress model.query )

    SetQuery query ->
      ( { model | query = query }, Effects.none )

    SetResults results ->
      ( { model | results = results }, Effects.none )

    SetErrorMessage errorMessage ->
      ( { model | errorMessage = errorMessage }, Effects.none )

    DeleteById idToHide ->
      let
        newResults =
          model.results
            |> List.filter (\{ id } -> id /= idToHide)

        newModel =
          { model | results = newResults }
      in
        ( newModel, Effects.none )

    DoNothing ->
      ( model, Effects.none )
