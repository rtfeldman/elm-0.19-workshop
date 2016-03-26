module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import StartApp.Simple as StartApp


main =
  StartApp.start
    { view = view
    , update = update
    , model = initialModel
    }


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
view model =
  div
    [ class "content" ]
    [ header
        []
        [ -- TODO add the equivalent of <h1>ElmHub</h1> right before the tagline
          span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
        ]
    , ul
        [ class "results" ]
        [{- TODO use model.results and viewSearchResults to display results -}]
    ]


viewSearchResult : SearchResult -> Html
viewSearchResult result =
  li
    []
    [ span [ class "star-count" ] [ text (toString result.stars) ]
      -- TODO replace the following with a link that opens in a new window!
    , text result.name
    ]
