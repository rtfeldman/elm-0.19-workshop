module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp.Simple as StartApp
import Json.Encode
import Signal exposing (Address)


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



{- See https://developer.github.com/v3/search/#example -}


initialModel : Model
initialModel =
  { query = "tutorial"
  , results =
      [ { id = 1
        , name = "TheSeamau5/elm-checkerboardgrid-tutorial"
        , stars = 66
        }
      , { id = 2
        , name = "grzegorzbalcerek/elm-by-example"
        , stars = 41
        }
      , { id = 3
        , name = "sporto/elm-tutorial-app"
        , stars = 35
        }
      , { id = 4
        , name = "jvoigtlaender/Elm-Tutorium"
        , stars = 10
        }
      , { id = 5
        , name = "sporto/elm-tutorial-assets"
        , stars = 7
        }
      ]
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
    , input
        [ class "search-query"
          -- TODO when we receive onInput, set the query in the model
        , defaultValue model.query
        ]
        []
    , button [ class "search-button" ] [ text "Search" ]
    , ul
        [ class "results" ]
        (List.map (viewSearchResult address) model.results)
    ]


onInput : Address Action -> (String -> Action) -> Attribute
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
        -- TODO add an onClick handler that sends a DeleteById action
        [ class "hide-result" ]
        [ text "X" ]
    ]


type Action
  = SetQuery String
  | DeleteById ResultId


update : Action -> Model -> Model
update action model =
  -- TODO if we get a SetQuery action, use it to set the model's query field,
  -- and if we get a DeleteById action, delete the appropriate result
  model


main =
  StartApp.start
    { view = view
    , update = update
    , model = initialModel
    }
