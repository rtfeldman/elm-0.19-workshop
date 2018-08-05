module Page.Article.Editor exposing (Model, Msg, initEdit, initNew, subscriptions, toSession, update, view)

import Api
import Article exposing (Article, Full)
import Article.Body exposing (Body)
import Article.Slug as Slug exposing (Slug)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (attribute, class, disabled, href, id, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import HttpBuilder exposing (withBody, withExpect)
import Json.Decode as Decode
import Json.Encode as Encode
import Loading
import Page
import Profile exposing (Profile)
import Route
import Session exposing (Session)
import Task exposing (Task)
import Time
import Validate exposing (Valid, Validator, fromValid, ifBlank, validate)
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)



-- MODEL


type alias Model =
    { session : Session
    , status : Status
    }


type
    Status
    -- Edit Article
    = Loading Slug
    | LoadingFailed Slug
    | Saving Slug Form
    | Editing Slug (List Error) Form
      -- New Article
    | EditingNew (List Error) Form
    | Creating Form


type alias Form =
    { title : String
    , body : String
    , description : String
    , tags : String
    }


initNew : Session -> ( Model, Cmd msg )
initNew session =
    ( { session = session
      , status =
            EditingNew []
                { title = ""
                , body = ""
                , description = ""
                , tags = ""
                }
      }
    , Cmd.none
    )


initEdit : Session -> Slug -> ( Model, Cmd Msg )
initEdit session slug =
    ( { session = session
      , status = Loading slug
      }
    , Article.fetch (Session.cred session) slug
        |> Http.toTask
        -- If init fails, store the slug that failed in the msg, so we can
        -- at least have it later to display the page's title properly!
        |> Task.mapError (\httpError -> ( slug, httpError ))
        |> Task.attempt CompletedArticleLoad
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title =
        case getSlug model.status of
            Just slug ->
                "Edit Article - " ++ Slug.toString slug

            Nothing ->
                "New Article"
    , content =
        case Session.cred model.session of
            Just cred ->
                viewAuthenticated cred model

            Nothing ->
                text "Sign in to edit this article."
    }


viewAuthenticated : Cred -> Model -> Html Msg
viewAuthenticated cred model =
    let
        formHtml =
            case model.status of
                Loading _ ->
                    [ Loading.icon ]

                Saving slug form ->
                    [ viewForm cred form (editArticleSaveButton [ disabled True ]) ]

                Creating form ->
                    [ viewForm cred form (newArticleSaveButton [ disabled True ]) ]

                Editing slug errors form ->
                    [ errors
                        |> List.map (\( _, error ) -> li [] [ text error ])
                        |> ul [ class "error-messages" ]
                    , viewForm cred form (editArticleSaveButton [])
                    ]

                EditingNew errors form ->
                    [ errors
                        |> List.map (\( _, error ) -> li [] [ text error ])
                        |> ul [ class "error-messages" ]
                    , viewForm cred form (newArticleSaveButton [])
                    ]

                LoadingFailed _ ->
                    [ text "Article failed to load." ]
    in
    div [ class "editor-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-10 offset-md-1 col-xs-12" ]
                    formHtml
                ]
            ]
        ]


viewForm : Cred -> Form -> Html Msg -> Html Msg
viewForm cred fields saveButton =
    Html.form [ onSubmit (ClickedSave cred) ]
        [ fieldset []
            [ fieldset [ class "form-group" ]
                [ input
                    [ class "form-control form-control-lg"
                    , placeholder "Article Title"
                    , onInput EnteredTitle
                    , value fields.title
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ input
                    [ class "form-control"
                    , placeholder "What's this article about?"
                    , onInput EnteredDescription
                    , value fields.description
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ textarea
                    [ class "form-control"
                    , placeholder "Write your article (in markdown)"
                    , attribute "rows" "8"
                    , onInput EnteredBody
                    , value fields.body
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ input
                    [ class "form-control"
                    , placeholder "Enter tags"
                    , onInput EnteredTags
                    , value fields.tags
                    ]
                    []
                ]
            , saveButton
            ]
        ]


editArticleSaveButton : List (Attribute msg) -> Html msg
editArticleSaveButton extraAttrs =
    saveArticleButton "Update Article" extraAttrs


newArticleSaveButton : List (Attribute msg) -> Html msg
newArticleSaveButton extraAttrs =
    saveArticleButton "Publish Article" extraAttrs


saveArticleButton : String -> List (Attribute msg) -> Html msg
saveArticleButton caption extraAttrs =
    button (class "btn btn-lg pull-xs-right btn-primary" :: extraAttrs)
        [ text caption ]



-- UPDATE


type Msg
    = ClickedSave Cred
    | EnteredBody String
    | EnteredDescription String
    | EnteredTags String
    | EnteredTitle String
    | CompletedCreate (Result Http.Error (Article Full))
    | CompletedEdit (Result Http.Error (Article Full))
    | CompletedArticleLoad (Result ( Slug, Http.Error ) (Article Full))
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedSave cred ->
            model.status
                |> save cred
                |> Tuple.mapFirst (\status -> { model | status = status })

        EnteredTitle title ->
            updateForm (\form -> { form | title = title }) model

        EnteredDescription description ->
            updateForm (\form -> { form | description = description }) model

        EnteredTags tags ->
            updateForm (\form -> { form | tags = tags }) model

        EnteredBody body ->
            updateForm (\form -> { form | body = body }) model

        CompletedCreate (Ok article) ->
            ( model
            , Route.Article (Article.slug article)
                |> Route.replaceUrl (Session.navKey model.session)
            )

        CompletedCreate (Err error) ->
            ( { model | status = savingError model.status }
            , Cmd.none
            )

        CompletedEdit (Ok article) ->
            ( model
            , Route.Article (Article.slug article)
                |> Route.replaceUrl (Session.navKey model.session)
            )

        CompletedEdit (Err error) ->
            ( { model | status = savingError model.status }
            , Cmd.none
            )

        CompletedArticleLoad (Err ( slug, error )) ->
            ( { model | status = LoadingFailed slug }
            , Cmd.none
            )

        CompletedArticleLoad (Ok article) ->
            let
                { title, description, tags } =
                    Article.metadata article

                status =
                    Editing (Article.slug article)
                        []
                        { title = title
                        , body = Article.Body.toMarkdownString (Article.body article)
                        , description = description
                        , tags = String.join " " tags
                        }
            in
            ( { model | status = status }
            , Cmd.none
            )

        GotSession session ->
            ( { model | session = session }, Cmd.none )


save : Cred -> Status -> ( Status, Cmd Msg )
save cred status =
    case status of
        Editing slug _ fields ->
            case validate formValidator fields of
                Ok validForm ->
                    ( Saving slug fields
                    , edit slug validForm cred
                        |> Http.send CompletedEdit
                    )

                Err errors ->
                    ( Editing slug errors fields
                    , Cmd.none
                    )

        EditingNew _ fields ->
            case validate formValidator fields of
                Ok validForm ->
                    ( Creating fields
                    , create validForm cred
                        |> Http.send CompletedCreate
                    )

                Err errors ->
                    ( EditingNew errors fields
                    , Cmd.none
                    )

        _ ->
            -- We're in a state where saving is not allowed.
            -- We tried to prevent getting here by disabling the Save
            -- button, but somehow the user got here anyway!
            --
            -- If we had an error logging service, we would send
            -- something to it here!
            ( status, Cmd.none )


savingError : Status -> Status
savingError status =
    let
        errors =
            [ ( Server, "Error saving article" ) ]
    in
    case status of
        Saving slug form ->
            Editing slug errors form

        Creating form ->
            EditingNew errors form

        _ ->
            status


{-| Helper function for `update`. Updates the form, if there is one,
and returns Cmd.none.

Useful for recording form fields!

This could also log errors to the server if we are trying to record things in
the form and we don't actually have a form.

-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    let
        newModel =
            case model.status of
                Loading _ ->
                    model

                LoadingFailed _ ->
                    model

                Saving slug form ->
                    { model | status = Saving slug (transform form) }

                Editing slug errors form ->
                    { model | status = Editing slug errors (transform form) }

                EditingNew errors form ->
                    { model | status = EditingNew errors (transform form) }

                Creating form ->
                    { model | status = Creating (transform form) }
    in
    ( newModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- VALIDATION


type ErrorSource
    = Server
    | Title
    | Body


type alias Error =
    ( ErrorSource, String )


formValidator : Validator Error Form
formValidator =
    Validate.all
        [ ifBlank .title ( Title, "title can't be blank." )
        , ifBlank .body ( Body, "body can't be blank." )
        ]



-- HTTP


create : Valid Form -> Cred -> Http.Request (Article Full)
create validForm cred =
    let
        form =
            fromValid validForm

        expect =
            Article.fullDecoder (Just cred)
                |> Decode.field "article"
                |> Http.expectJson

        article =
            Encode.object
                [ ( "title", Encode.string form.title )
                , ( "description", Encode.string form.description )
                , ( "body", Encode.string form.body )
                , ( "tagList", Encode.list Encode.string (tagsFromString form.tags) )
                ]

        jsonBody =
            Encode.object [ ( "article", article ) ]
                |> Http.jsonBody
    in
    Api.url [ "articles" ]
        |> HttpBuilder.post
        |> Cred.addHeader cred
        |> withBody jsonBody
        |> withExpect expect
        |> HttpBuilder.toRequest


tagsFromString : String -> List String
tagsFromString str =
    str
        |> String.split " "
        |> List.map String.trim
        |> List.filter (not << String.isEmpty)


edit : Slug -> Valid Form -> Cred -> Http.Request (Article Full)
edit articleSlug validForm cred =
    let
        form =
            fromValid validForm

        expect =
            Article.fullDecoder (Just cred)
                |> Decode.field "article"
                |> Http.expectJson

        article =
            Encode.object
                [ ( "title", Encode.string form.title )
                , ( "description", Encode.string form.description )
                , ( "body", Encode.string form.body )
                ]

        jsonBody =
            Encode.object [ ( "article", article ) ]
                |> Http.jsonBody
    in
    Article.url articleSlug []
        |> HttpBuilder.put
        |> Cred.addHeader cred
        |> withBody jsonBody
        |> withExpect expect
        |> HttpBuilder.toRequest



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session



-- INTERNAL


{-| Used for setting the page's title.
-}
getSlug : Status -> Maybe Slug
getSlug status =
    case status of
        Loading slug ->
            Just slug

        LoadingFailed slug ->
            Just slug

        Saving slug _ ->
            Just slug

        Editing slug _ _ ->
            Just slug

        EditingNew _ _ ->
            Nothing

        Creating _ ->
            Nothing
