module Page.Home exposing (initialModel, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)


-- MODEL --


initialModel =
    { tags = [ "foo", "bar", "dragons" ]
    , selectedTag = ""
    }



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


viewTags model =
    div [ class "tag-list" ] (List.map viewTag model.tags)


viewTag tagName =
    let
        classname =
            {- TODO Change this if-expression to be more useful:

                  if tagName == selectedTag then

               Then change viewTag to take selectedTag as its first argument:

                  viewTag selectedTag tagName =
            -}
            if tagName == tagName then
                "tag-pill tag-default"
            else
                "tag-pill tag-selected"
    in
    button
        [ class classname

        {- TODO add an onClick handler here which selects the given tag.

           HINT: This will require coordination with the update function!
        -}
        ]
        [ text tagName ]


viewFeed feed =
    div [ class "feed-toggle" ] [ text "(We’ll display some articles here later.)" ]



-- UPDATE --


update msg model =
    if msg.operation == "SELECT_TAG" then
        -- TODO Return `model` with the `selectedTag` field set to `msg.data`
        model
    else
        model
