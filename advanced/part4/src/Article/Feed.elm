module Article.Feed
    exposing
        ( FeedConfig
        , ListConfig
        , Model
        , Msg
        , defaultFeedConfig
        , defaultListConfig
        , init
        , selectTag
        , update
        , viewArticles
        , viewFeedSources
        )

import Api
import Article exposing (Article, Preview)
import Article.FeedSources as FeedSources exposing (FeedSources, Source(..))
import Article.Preview
import Article.Slug as ArticleSlug exposing (Slug)
import Article.Tag as Tag exposing (Tag)
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
import Session exposing (Session)
import Task exposing (Task)
import Time
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
            viewPaginatedList articles (limit feedSource)
    in
    List.append articlesHtml [ pagination ]


{-| 👉 TODO Move this logic into PaginatedList.view and make it reusable,
so we can use it on other pages too!

💡 HINT: Make `PaginatedList.view` return `Html msg` instead of `Html Msg`. (The function will need to accept an extra argument for this to work.)

-}
viewPaginatedList : PaginatedList a -> Int -> Html Msg
viewPaginatedList paginatedList resultsPerPage =
    let
        totalPages =
            ceiling (toFloat (PaginatedList.total paginatedList) / toFloat resultsPerPage)

        activePage =
            PaginatedList.page paginatedList

        viewPageLink currentPage =
            pageLink ClickedFeedPage currentPage (currentPage == activePage)
    in
    if totalPages > 1 then
        List.range 1 totalPages
            |> List.map viewPageLink
            |> ul [ class "pagination" ]

    else
        Html.text ""


pageLink : Int -> Bool -> Html Msg
pageLink targetPage isActive =
    li [ classList [ ( "page-item", True ), ( "active", isActive ) ] ]
        [ a
            [ class "page-link"
            , onClick (toMsg targetPage)

            -- The RealWorld CSS requires an href to work properly.
            , href ""
            ]
            [ text (String.fromInt targetPage) ]
        ]


viewPreview : Maybe Cred -> Time.Zone -> Article Preview -> Html Msg
viewPreview maybeCred timeZone article =
    let
        slug =
            Article.slug article

        config =
            case maybeCred of
                Just cred ->
                    Just
                        { cred = cred
                        , favorite = ClickedFavorite cred slug
                        , unfavorite = ClickedUnfavorite cred slug
                        }

                Nothing ->
                    Nothing
    in
    Article.Preview.view config timeZone article


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

        listConfig =
            { defaultListConfig | offset = offset, limit = articlesPerPage }
    in
    Task.map (PaginatedList.mapPage (\_ -> page)) <|
        case feedSource of
            YourFeed cred ->
                let
                    feedConfig =
                        { defaultFeedConfig | offset = offset, limit = articlesPerPage }
                in
                feed feedConfig cred
                    |> Http.toTask

            GlobalFeed ->
                list listConfig maybeCred
                    |> Http.toTask

            TagFeed tagName ->
                list { listConfig | tag = Just tagName } maybeCred
                    |> Http.toTask

            FavoritedFeed username ->
                list { listConfig | favorited = Just username } maybeCred
                    |> Http.toTask

            AuthorFeed username ->
                list { listConfig | author = Just username } maybeCred
                    |> Http.toTask


replaceArticle : Article a -> Article a -> Article a
replaceArticle newArticle oldArticle =
    if Article.slug newArticle == Article.slug oldArticle then
        newArticle

    else
        oldArticle



-- LIST


type alias ListConfig =
    { tag : Maybe Tag
    , author : Maybe Username
    , favorited : Maybe Username
    , limit : Int
    , offset : Int
    }


defaultListConfig : ListConfig
defaultListConfig =
    { tag = Nothing
    , author = Nothing
    , favorited = Nothing
    , limit = 20
    , offset = 0
    }


list : ListConfig -> Maybe Cred -> Http.Request (PaginatedList (Article Preview))
list config maybeCred =
    [ Maybe.map (\tag -> ( "tag", Tag.toString tag )) config.tag
    , Maybe.map (\author -> ( "author", Username.toString author )) config.author
    , Maybe.map (\favorited -> ( "favorited", Username.toString favorited )) config.favorited
    , Just ( "limit", String.fromInt config.limit )
    , Just ( "offset", String.fromInt config.offset )
    ]
        |> List.filterMap identity
        |> buildFromQueryParams maybeCred (Api.url [ "articles" ])
        |> Cred.addHeaderIfAvailable maybeCred
        |> HttpBuilder.toRequest



-- FEED


type alias FeedConfig =
    { limit : Int
    , offset : Int
    }


defaultFeedConfig : FeedConfig
defaultFeedConfig =
    { limit = 10
    , offset = 0
    }


feed : FeedConfig -> Cred -> Http.Request (PaginatedList (Article Preview))
feed config cred =
    [ ( "limit", String.fromInt config.limit )
    , ( "offset", String.fromInt config.offset )
    ]
        |> buildFromQueryParams (Just cred) (Api.url [ "articles", "feed" ])
        |> Cred.addHeader cred
        |> HttpBuilder.toRequest



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
