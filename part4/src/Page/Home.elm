module Page.Home exposing (initialModel, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)


-- TYPES --


type alias Msg =
    { operation : String
    , data : String
    }


type alias Model =
    { tags : List String
    , selectedTag : String
    }



-- MODEL --


initialModel : Model
initialModel =
    { tags = [ "foo", "bar", "dragons" ]
    , selectedTag = ""
    }



-- VIEW --


viewBanner : Html Msg
viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "conduit" ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ]
                    [ div [ class "feed-toggle" ]
                        [ text "(We’ll display some articles here later.)" ]
                    ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]
                        , div [ class "tag-list" ]
                            (List.map (viewTag model.selectedTag) model.tags)
                        ]
                    ]
                ]
            ]
        ]


viewTag : String -> String -> Html Msg
viewTag selectedTagName tagName =
    let
        classname =
            if tagName == selectedTagName then
                "tag-pill tag-selected"
            else
                "tag-pill tag-default"
    in
    button
        [ class classname
        , onClick { operation = "SELECT_TAG", data = tagName }
        ]
        [ text tagName ]



-- UPDATE --


update : Msg -> Model -> Model
update msg model =
    if msg.operation == "SELECT_TAG" then
        { model | selectedTag = msg.data }
    else
        model
