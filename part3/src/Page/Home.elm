module Page.Home exposing (initialModel, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)


-- MODEL --


initialModel =
    { tags = [ "foo", "bar", "baz", "dragons", "tag name goes here" ]
    , selectedTag = ""
    }



-- UPDATE --


update msg model =
    if msg.operation == "SELECT_TAG" then
        { model | selectedTag = msg.data }
    else
        model



-- VIEW --


view model =
    div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ] [ viewFeed [] ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]
                        , viewTags model
                        ]
                    ]
                ]
            ]
        ]


viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "conduit" ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]


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


viewTags model =
    div [ class "tag-list" ] (List.map (viewTag model.selectedTag) model.tags)


viewFeed feed =
    div [ class "feed-toggle" ] [ text "(We’ll display some articles here later.)" ]
