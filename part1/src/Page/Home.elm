module Page.Home exposing (page)

import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)


page =
    div [ class "home-page" ]
        [ p [] [ text "TODO: Replace this <p> with the banner" ]
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ] [ feed ]
                , div [ class "col-md-3" ] []
                ]
            ]
        ]


banner =
    {- TODO Add a logo and tagline to this banner, so its structure becomes:

          <div class="banner">
              <div class="container">
                  <h1 class="logo-font">conduit</h1>
                  <p>A place to share your knowledge.</p>
               </div>
          </div>

       HINT 1: the <div class="row"> above is an element with 2 child nodes.

       HINT 2: the <div class="feed-toggle"> below is an element with text.
    -}
    div [ class "banner" ]
        [ div [ class "container" ]
            [ text "TODO: Put a <h1> here instead of this text, then add a <p> right after the <h1>" ]
        ]


feed =
    div [ class "feed-toggle" ] [ text "(In the future we’ll display a feed of articles here!)" ]
