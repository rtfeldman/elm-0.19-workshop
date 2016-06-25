module Main exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


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


elmHubHeader : Html a
elmHubHeader =
    header []
        [ h1 [] [ text "ElmHub" ]
        , span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
        ]


{-| TODO revise this type annotation once we add our onClick handler
-}
view : Model -> Html a
view model =
    div [ class "content" ]
        [ elmHubHeader
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


{-| TODO revise this type annotation once we add our onClick handler
-}
viewSearchResult : SearchResult -> Html a
viewSearchResult result =
    li []
        [ span [ class "star-count" ] [ text (toString result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button
            -- TODO add an onClick handler that sends a DELETE_BY_ID action
            [ class "hide-result" ]
            [ text "X" ]
        ]


type alias Msg =
    { -- TODO implement this type alias
    }


update : Msg -> Model -> Model
update msg model =
    -- TODO if we receive a DELETE_BY_ID message,
    -- build a new model without the given ID present anymore.
    model


main : Program Never
main =
    Html.App.beginnerProgram
        { view = view
        , update = update
        , model = initialModel
        }
