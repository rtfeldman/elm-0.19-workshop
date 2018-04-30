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


{-| TODO add a type annotation to initialModel
-}
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


{-| TODO add a type annotation to view
-}
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


{-| TODO add a type annotation to viewTag
-}
viewTag selectedTag tagName =
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



-- UPDATE --


{-| TODO add a type annotation to update
-}
update msg model =
    if msg.operation == "SELECT_TAG" then
        -- TODO Return `model` with the `selectedTag` field set to `msg.data`
        model
    else
        model
