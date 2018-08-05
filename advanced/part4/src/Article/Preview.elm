module Article.Preview exposing (view)

{-| A preview of an individual article, excluding its body.
-}

import Article exposing (Article)
import Author
import Avatar exposing (Avatar)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder, src)
import Profile
import Route exposing (Route)
import Time
import Timestamp
import Viewer.Cred exposing (Cred)



-- VIEW


view : Maybe { cred : Cred, favorite : msg, unfavorite : msg } -> Time.Zone -> Article a -> Html msg
view config timeZone article =
    let
        { title, description, createdAt } =
            Article.metadata article

        author =
            Article.author article

        profile =
            Author.profile author

        username =
            Author.username author

        faveButton =
            case config of
                Just { favorite, unfavorite, cred } ->
                    let
                        { favoritesCount, favorited } =
                            Article.metadata article

                        viewButton =
                            if favorited then
                                Article.unfavoriteButton cred unfavorite

                            else
                                Article.favoriteButton cred favorite
                    in
                    viewButton [ class "pull-xs-right" ]
                        [ text (" " ++ String.fromInt favoritesCount) ]

                Nothing ->
                    text ""
    in
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ Route.href (Route.Profile username) ]
                [ img [ Avatar.src (Profile.avatar profile) ] [] ]
            , div [ class "info" ]
                [ Author.view username
                , Timestamp.view timeZone createdAt
                ]
            , faveButton
            ]
        , a [ class "preview-link", Route.href (Route.Article (Article.slug article)) ]
            [ h1 [] [ text title ]
            , p [] [ text description ]
            , span [] [ text "Read more..." ]
            ]
        ]
