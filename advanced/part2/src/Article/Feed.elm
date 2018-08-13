module Article.Feed
    exposing
        ( Model
        , Msg
        , init
        , selectTag
        , update
        , viewArticles
        , viewFeedSources
        )

import Api
import Article exposing (Article, Preview)
import Article.FeedSources as FeedSources exposing (FeedSources, Source(..))
import Article.Slug as ArticleSlug exposing (Slug)
import Article.Tag as Tag exposing (Tag)
import Author
import Avatar exposing (Avatar)
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder, src)
import Html.Events exposing (onClick)
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Page
import PaginatedList exposing (PaginatedList)
import Profile
import Route exposing (Route)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Timestamp
import Username exposing (Username)
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)


{-| NOTE: This module has its own Model, view, and update. This is not normal!
If you find yourself doing this often, please watch <https://www.youtube.com/watch?v=DoA4Txr4GUs>

This is the reusable Article Feed that appears on both the Home page as well as
on the Profile page. There's a lot of logic here, so it's more convenient to use
the heavyweight approach of giving this its own Model, view, and update.

This means callers must use Html.map and Cmd.map to use this thing, but in
this case that's totally worth it because of the amount of logic wrapped up
in this thing.

For every other reusable view in this application, this API would be totally
overkill, so we use simpler APIs instead.

-}



-- MODEL


type Model
    = Model InternalModel


{-| This should not be exposed! We want to benefit from the guarantee that only
this module can create or alter this model. This way if it ever ends up in
a surprising state, we know exactly where to look: this module.
-}
type alias InternalModel =
    { session : Session
    , errors : List String
    , articles : PaginatedList (Article Preview)
    , sources : FeedSources
    , isLoading : Bool
    }


init : Session -> FeedSources -> Task Http.Error Model
init session sources =
    let
        fromArticles articles =
            Model
                { session = session
                , errors = []
                , articles = articles
                , sources = sources
                , isLoading = False
                }
    in
    FeedSources.selected sources
        |> fetch (Session.cred session) 1
        |> Task.map fromArticles



-- VIEW


viewArticles : Time.Zone -> Model -> List (Html Msg)
viewArticles timeZone (Model { articles, sources, session }) =
    let
        maybeCred =
            Session.cred session

        articlesHtml =
            PaginatedList.values articles
                |> List.map (viewPreview maybeCred timeZone)

        feedSource =
            FeedSources.selected sources

        pagination =
            PaginatedList.view ClickedFeedPage articles (limit feedSource)
    in
    List.append articlesHtml [ pagination ]


viewPreview : Maybe Cred -> Time.Zone -> Article Preview -> Html Msg
viewPreview maybeCred timeZone article =
    let
        slug =
            Article.slug article

        { title, description, createdAt } =
            Article.metadata article

        author =
            Article.author article

        profile =
            Author.profile author

        username =
            Author.username author

        faveButton =
            case maybeCred of
                Just cred ->
                    let
                        { favoritesCount, favorited } =
                            Article.metadata article

                        viewButton =
                            if favorited then
                                Article.unfavoriteButton cred (ClickedUnfavorite cred slug)

                            else
                                Article.favoriteButton cred (ClickedFavorite cred slug)
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


viewFeedSources : Model -> Html Msg
viewFeedSources (Model { sources, isLoading, errors }) =
    let
        errorsHtml =
            Page.viewErrors ClickedDismissErrors errors
    in
    ul [ class "nav nav-pills outline-active" ] <|
        List.concat
            [ List.map (viewFeedSource False) (FeedSources.before sources)
            , [ viewFeedSource True (FeedSources.selected sources) ]
            , List.map (viewFeedSource False) (FeedSources.after sources)
            , [ errorsHtml ]
            ]


viewFeedSource : Bool -> Source -> Html Msg
viewFeedSource isSelected source =
    li [ class "nav-item" ]
        [ a
            [ classList [ ( "nav-link", True ), ( "active", isSelected ) ]
            , onClick (ClickedFeedSource source)

            -- The RealWorld CSS requires an href to work properly.
            , href ""
            ]
            [ text (sourceName source) ]
        ]


selectTag : Maybe Cred -> Tag -> Cmd Msg
selectTag maybeCred tag =
    let
        source =
            TagFeed tag
    in
    fetch maybeCred 1 source
        |> Task.attempt (CompletedFeedLoad source)


sourceName : Source -> String
sourceName source =
    case source of
        YourFeed _ ->
            "Your Feed"

        GlobalFeed ->
            "Global Feed"

        TagFeed tagName ->
            "#" ++ Tag.toString tagName

        FavoritedFeed username ->
            "Favorited Articles"

        AuthorFeed username ->
            "My Articles"


limit : Source -> Int
limit feedSource =
    case feedSource of
        YourFeed _ ->
            10

        GlobalFeed ->
            10

        TagFeed tagName ->
            10

        FavoritedFeed username ->
            5

        AuthorFeed username ->
            5



-- UPDATE


type Msg
    = ClickedDismissErrors
    | ClickedFavorite Cred Slug
    | ClickedUnfavorite Cred Slug
    | ClickedFeedPage Int
    | ClickedFeedSource Source
    | CompletedFavorite (Result Http.Error (Article Preview))
    | CompletedFeedLoad Source (Result Http.Error (PaginatedList (Article Preview)))


update : Maybe Cred -> Msg -> Model -> ( Model, Cmd Msg )
update maybeCred msg (Model model) =
    case msg of
        ClickedDismissErrors ->
            ( Model { model | errors = [] }, Cmd.none )

        ClickedFeedSource source ->
            ( Model { model | isLoading = True }
            , source
                |> fetch maybeCred 1
                |> Task.attempt (CompletedFeedLoad source)
            )

        CompletedFeedLoad source (Ok articles) ->
            ( Model
                { model
                    | articles = articles
                    , sources = FeedSources.select source model.sources
                    , isLoading = False
                }
            , Cmd.none
            )

        CompletedFeedLoad _ (Err error) ->
            ( Model
                { model
                    | errors = Api.addServerError model.errors
                    , isLoading = False
                }
            , Cmd.none
            )

        ClickedFavorite cred slug ->
            fave Article.favorite cred slug model

        ClickedUnfavorite cred slug ->
            fave Article.unfavorite cred slug model

        CompletedFavorite (Ok article) ->
            ( Model { model | articles = PaginatedList.map (replaceArticle article) model.articles }
            , Cmd.none
            )

        CompletedFavorite (Err error) ->
            ( Model { model | errors = Api.addServerError model.errors }
            , Cmd.none
            )

        ClickedFeedPage page ->
            let
                source =
                    FeedSources.selected model.sources
            in
            ( Model model
            , fetch maybeCred page source
                |> Task.andThen (\articles -> Task.map (\_ -> articles) scrollToTop)
                |> Task.attempt (CompletedFeedLoad source)
            )


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())


fetch : Maybe Cred -> Int -> Source -> Task Http.Error (PaginatedList (Article Preview))
fetch maybeCred page feedSource =
    let
        articlesPerPage =
            limit feedSource

        offset =
            (page - 1) * articlesPerPage

        params =
            [ ( "limit", String.fromInt articlesPerPage )
            , ( "offset", String.fromInt offset )
            ]
    in
    Task.map (PaginatedList.mapPage (\_ -> page)) <|
        case feedSource of
            YourFeed cred ->
                params
                    |> buildFromQueryParams (Just cred) (Api.url [ "articles", "feed" ])
                    |> Cred.addHeader cred
                    |> HttpBuilder.toRequest
                    |> Http.toTask

            GlobalFeed ->
                list maybeCred params

            TagFeed tagName ->
                list maybeCred (( "tag", Tag.toString tagName ) :: params)

            FavoritedFeed username ->
                list maybeCred (( "favorited", Username.toString username ) :: params)

            AuthorFeed username ->
                list maybeCred (( "author", Username.toString username ) :: params)


list :
    Maybe Cred
    -> List ( String, String )
    -> Task Http.Error (PaginatedList (Article Preview))
list maybeCred params =
    buildFromQueryParams maybeCred (Api.url [ "articles" ]) params
        |> Cred.addHeaderIfAvailable maybeCred
        |> HttpBuilder.toRequest
        |> Http.toTask


replaceArticle : Article a -> Article a -> Article a
replaceArticle newArticle oldArticle =
    if Article.slug newArticle == Article.slug oldArticle then
        newArticle

    else
        oldArticle



-- SERIALIZATION


decoder : Maybe Cred -> Decoder (PaginatedList (Article Preview))
decoder maybeCred =
    Decode.succeed PaginatedList.fromList
        |> required "articlesCount" Decode.int
        |> required "articles" (Decode.list (Article.previewDecoder maybeCred))



-- REQUEST


buildFromQueryParams : Maybe Cred -> String -> List ( String, String ) -> RequestBuilder (PaginatedList (Article Preview))
buildFromQueryParams maybeCred url queryParams =
    HttpBuilder.get url
        |> withExpect (Http.expectJson (decoder maybeCred))
        |> withQueryParams queryParams



-- INTERNAL


fave : (Slug -> Cred -> Http.Request (Article Preview)) -> Cred -> Slug -> InternalModel -> ( Model, Cmd Msg )
fave toRequest cred slug model =
    ( Model model
    , toRequest slug cred
        |> Http.toTask
        |> Task.attempt CompletedFavorite
    )
