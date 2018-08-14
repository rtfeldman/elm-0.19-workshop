module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api
import Article exposing (Article, Preview)
import Article.Feed as Feed
import Article.FeedSources as FeedSources exposing (FeedSources, Source(..))
import Article.Tag as Tag exposing (Tag)
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Html.Events exposing (onClick)
import Http
import HttpBuilder
import Loading
import Log
import Page
import PaginatedList exposing (PaginatedList)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Username exposing (Username)
import Viewer.Cred as Cred exposing (Cred)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , feedTab : FeedTab
    , feedPage : Int

    -- Loaded independently from server
    , tags : Status (List Tag)
    , feed : Status Feed.Model
    }


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


type FeedTab
    = YourFeed
    | GlobalFeed
    | TagFeed String


init : Session -> ( Model, Cmd Msg )
init session =
    let
        feedTab =
            case Session.cred session of
                Just _ ->
                    YourFeed

                Nothing ->
                    GlobalFeed

        loadTags =
            Http.toTask Tag.list
    in
    ( { session = session
      , timeZone = Time.utc
      , feedTab = feedTab
      , feedPage = 1
      , tags = Loading
      , feed = Loading
      }
    , Cmd.batch
        [ fetchFeed session feedTab 1
            |> Task.attempt CompletedFeedLoad
        , Tag.list
            |> Http.send CompletedTagsLoad
        , Task.perform GotTimeZone Time.here
        , Task.perform (\_ -> PassedSlowLoadThreshold) Loading.slowThreshold
        ]
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Conduit"
    , content =
        div [ class "home-page" ]
            [ viewBanner
            , div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-9" ] <|
                        case model.feed of
                            Loaded feed ->
                                [ div [ class "feed-toggle" ] <|
                                    List.concat
                                        [ [ viewTabs (Session.cred model.session /= Nothing) model.feedTab ]
                                        , Feed.viewArticles model.timeZone feed
                                            |> List.map (Html.map GotFeedMsg)
                                        , [ Feed.viewPagination ClickedFeedPage feed ]
                                        ]
                                ]

                            Loading ->
                                []

                            LoadingSlowly ->
                                [ Loading.icon ]

                            Failed ->
                                [ Loading.error "feed" ]
                    , div [ class "col-md-3" ] <|
                        case model.tags of
                            Loaded tags ->
                                [ div [ class "sidebar" ] <|
                                    [ p [] [ text "Popular Tags" ]
                                    , viewTags tags
                                    ]
                                ]

                            Loading ->
                                []

                            LoadingSlowly ->
                                [ Loading.icon ]

                            Failed ->
                                [ Loading.error "tags" ]
                    ]
                ]
            ]
    }


viewBanner : Html msg
viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "conduit" ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]



-- TABS


{-| TODO: Have viewTabs render all the tabs, using `activeTab` as the
single source of truth for their state.

    The specification for how the tabs work is:

    1. If the user is logged in, render `yourFeed` as the first tab. Examples:

    "Your Feed"    "Global Feed"
    "Your Feed"    "Global Feed"  "#dragons"

    2. If the user is NOT logged in, do not render `yourFeed` at all. Examples:

    "Global Feed"
    "Global Feed"  "#dragons"

    3. If the active tab is a `TagFeed`, render that tab last. Show the tag it contains with a "#" in front.

    "Global Feed"  "#dragons"
    "Your Feed"    "Global Feed"  "#dragons"

    3. If the active tab is NOT a `TagFeed`, do not render a tag tab at all.

    "Your Feed"    "Global Feed"
    "Global Feed"

    💡 HINT: The 4 declarations after `viewTabs` may be helpful!

-}
viewTabs : Bool -> FeedTab -> Html Msg
viewTabs isLoggedIn activeTab =
    ul [ class "nav nav-pills outline-active" ] <|
        case activeTab of
            YourFeed ->
                []

            GlobalFeed ->
                []

            TagFeed tagName ->
                []


tabBar :
    List ( String, msg )
    -> ( String, msg )
    -> List ( String, msg )
    -> Html msg
tabBar before selected after =
    ul [ class "nav nav-pills outline-active" ] <|
        List.concat
            [ List.map (viewTab []) before
            , [ viewTab [ class "active" ] selected ]
            , List.map (viewTab []) after
            ]


viewTab : List (Attribute msg) -> ( String, msg ) -> Html msg
viewTab attrs ( name, msg ) =
    li [ class "nav-item" ]
        [ -- Note: The RealWorld CSS requires an href to work properly.
          a (class "nav-link" :: onClick msg :: href "" :: attrs)
            [ text name ]
        ]


yourFeed : ( String, Msg )
yourFeed =
    ( "Your Feed", ClickedTab YourFeed )


globalFeed : ( String, Msg )
globalFeed =
    ( "Global Feed", ClickedTab GlobalFeed )


tagFeed : String -> ( String, Msg )
tagFeed tag =
    ( "#" ++ tag, ClickedTab (TagFeed tag) )



-- TAGS


viewTags : List Tag -> Html Msg
viewTags tags =
    div [ class "tag-list" ] (List.map viewTag tags)


viewTag : Tag -> Html Msg
viewTag tagName =
    a
        [ class "tag-pill tag-default"
        , onClick (ClickedTag tagName)

        -- The RealWorld CSS requires an href to work properly.
        , href ""
        ]
        [ text (Tag.toString tagName) ]



-- UPDATE


type Msg
    = ClickedTag Tag
    | ClickedTab FeedTab
    | ClickedFeedPage Int
    | CompletedFeedLoad (Result Http.Error Feed.Model)
    | CompletedTagsLoad (Result Http.Error (List Tag))
    | GotTimeZone Time.Zone
    | GotFeedMsg Feed.Msg
    | GotSession Session
    | PassedSlowLoadThreshold


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedTag tag ->
            let
                feedTab =
                    TagFeed (Tag.toString tag)
            in
            ( { model | feedTab = feedTab }
            , fetchFeed model.session feedTab 1
                |> Task.attempt CompletedFeedLoad
            )

        ClickedTab tab ->
            ( { model | feedTab = tab }
            , fetchFeed model.session tab 1
                |> Task.attempt CompletedFeedLoad
            )

        ClickedFeedPage page ->
            ( { model | feedPage = page }
            , fetchFeed model.session model.feedTab page
                |> Task.andThen (\feed -> Task.map (\_ -> feed) scrollToTop)
                |> Task.attempt CompletedFeedLoad
            )

        CompletedFeedLoad (Ok feed) ->
            ( { model | feed = Loaded feed }, Cmd.none )

        CompletedFeedLoad (Err error) ->
            ( { model | feed = Failed }, Cmd.none )

        CompletedTagsLoad (Ok tags) ->
            ( { model | tags = Loaded tags }, Cmd.none )

        CompletedTagsLoad (Err error) ->
            ( { model | tags = Failed }
            , Log.error
            )

        GotFeedMsg subMsg ->
            case model.feed of
                Loaded feed ->
                    let
                        ( newFeed, subCmd ) =
                            Feed.update (Session.cred model.session) subMsg feed
                    in
                    ( { model | feed = Loaded newFeed }
                    , Cmd.map GotFeedMsg subCmd
                    )

                Loading ->
                    ( model, Log.error )

                LoadingSlowly ->
                    ( model, Log.error )

                Failed ->
                    ( model, Log.error )

        GotTimeZone tz ->
            ( { model | timeZone = tz }, Cmd.none )

        GotSession session ->
            ( { model | session = session }, Cmd.none )

        PassedSlowLoadThreshold ->
            let
                -- If any data is still Loading, change it to LoadingSlowly
                -- so `view` knows to render a spinner.
                feed =
                    case model.feed of
                        Loading ->
                            LoadingSlowly

                        other ->
                            other

                tags =
                    case model.tags of
                        Loading ->
                            LoadingSlowly

                        other ->
                            other
            in
            ( { model | feed = feed, tags = tags }, Cmd.none )



-- HTTP


fetchFeed : Session -> FeedTab -> Int -> Task Http.Error Feed.Model
fetchFeed session feedTabs page =
    let
        maybeCred =
            Session.cred session

        builder =
            case feedTabs of
                YourFeed ->
                    Api.url [ "articles", "feed" ]
                        |> HttpBuilder.get
                        |> Cred.addHeaderIfAvailable maybeCred

                GlobalFeed ->
                    Api.url [ "articles" ]
                        |> HttpBuilder.get
                        |> Cred.addHeaderIfAvailable maybeCred

                TagFeed tagName ->
                    Api.url [ "articles" ]
                        |> HttpBuilder.get
                        |> Cred.addHeaderIfAvailable maybeCred
                        |> HttpBuilder.withQueryParam "tag" tagName
    in
    builder
        |> HttpBuilder.withExpect (Http.expectJson (Feed.decoder maybeCred articlesPerPage))
        |> PaginatedList.fromRequestBuilder articlesPerPage page
        |> Task.map (Feed.init session)


articlesPerPage : Int
articlesPerPage =
    10


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
