module Page.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)


view tags =
    div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ] [ viewFeed ]
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]

                        -- TODO pass the actual tags to viewTags
                        , viewTags []
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


viewFeed =
    div [ class "feed-toggle" ] [ text "(We’ll display some articles here later.)" ]


viewTags tags =
    let
        renderedTags =
            -- TODO use List.map to render the tags
            []
    in
    div [ class "tag-list" ] renderedTags


viewTag tagName =
    {- TODO render something like this:

       <button class="tag-pill tag-default">tag name goes here</button>
    -}
    button [] []
