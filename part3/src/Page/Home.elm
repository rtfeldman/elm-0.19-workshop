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



-- UPDATE --


update msg model =
    if msg.operation == "SELECT_TAG" then
        {- TODO Return `model` with the `selectedTag` field set to `msg.data`

           HINT: Record update syntax looks like this:

               { model | foo = bar }
        -}
        model
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


{-| TODO Give this function a new first argument called `selectedTag`, like so:

BEFORE:

    viewTag tagName =

AFTER:

    viewTag selectedTag tagName =

HINT: This will cause a compiler error. See where the error message takes you!

-}
viewTag tagName =
    let
        classname =
            {- TODO Set the classname to "tag-pill tag-selected" only
               when tagName == selectedTag
            -}
            if False then
                "tag-pill tag-selected"
            else
                "tag-pill tag-default"
    in
    {- TODO add an onClick handler here which selects `tagName`

       HINT: Take look at `update` above, to check what it expects `msg`
             to be. It will look something like this:

        button
            [ class classname
            , onClick { operation = "SOMETHING", data = "tag name goes here" }
            ]
            [ text tagName ]
    -}
    button
        [ class classname
        ]
        [ text tagName ]


{-| HINT: Take a look at how initialModel is defined at the top of this file.
-}
viewTags model =
    div [ class "tag-list" ]
        (List.map (\tag -> viewTag tag) model.tags)


viewFeed feed =
    div [ class "feed-toggle" ] [ text "(We’ll display some articles here later.)" ]
