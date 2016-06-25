module Main exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)


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


view : Model -> Html Msg
view model =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "“Like GitHub, but for Elm things.”" ]
            ]
        , input
            [ class "search-query"
              -- TODO onInput, set the query in the model
            , defaultValue model.query
            ]
            []
        , button [ class "search-button" ] [ text "Search" ]
        , ul [ class "results" ] (List.map viewSearchResult model.results)
        ]


viewSearchResult : SearchResult -> Html Msg
viewSearchResult result =
    li []
        [ span [ class "star-count" ] [ text (toString result.stars) ]
        , a [ href ("https://github.com/" ++ result.name), target "_blank" ]
            [ text result.name ]
        , button
            -- TODO add an onClick handler that sends a DeleteById action
            [ class "hide-result" ]
            [ text "X" ]
        ]


type Msg
    = SetQuery String
    | DeleteById ResultId


update : Msg -> Model -> Model
update msg model =
    -- TODO if we get a SetQuery action, use it to set the model's query field,
    -- and if we get a DeleteById action, delete the appropriate result
    model


main : Program Never
main =
    Html.App.beginnerProgram
        { view = view
        , update = update
        , model = initialModel
        }
