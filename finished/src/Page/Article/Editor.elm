module Page.Article.Editor exposing (Model, Msg, initEdit, initNew, update, view)

import Data.Article as Article exposing (Article, Body)
import Data.Article.Tag as Tag exposing (Tag)
import Data.Session exposing (Session)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, defaultValue, disabled, href, id, placeholder, type_)
import Html.Events exposing (onInput, onSubmit)
import Http
import Page.Errored exposing (PageLoadError, pageLoadError)
import Parser
import Request.Article
import Route
import Task exposing (Task)
import Util exposing (pair, viewIf)
import Validate exposing (Validator, ifBlank, validate)
import Views.Form as Form
import Views.Page as Page


-- MODEL --


type alias Model =
    { errors : List Error
    , editingArticle : Maybe Article.Slug
    , title : String
    , body : String
    , description : String
    , tags : String
    , isSaving : Bool
    }


initNew : Model
initNew =
    { errors = []
    , editingArticle = Nothing
    , title = ""
    , body = ""
    , description = ""
    , tags = ""
    , isSaving = False
    }


initEdit : Session -> Article.Slug -> Task PageLoadError Model
initEdit session slug =
    let
        maybeAuthToken =
            session.user
                |> Maybe.map .token
    in
    Request.Article.get maybeAuthToken slug
        |> Http.toTask
        |> Task.mapError (\_ -> pageLoadError Page.Other "Article is currently unavailable.")
        |> Task.map
            (\article ->
                { errors = []
                , editingArticle = Just slug
                , title = article.title
                , body = Article.bodyToMarkdownString article.body
                , description = article.description
                , tags = String.join " " article.tags
                , isSaving = False
                }
            )



-- VIEW --


view : Model -> Html Msg
view model =
    div [ class "editor-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-10 offset-md-1 col-xs-12" ]
                    [ Form.viewErrors model.errors
                    , viewForm model
                    ]
                ]
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
    let
        isEditing =
            model.editingArticle /= Nothing

        saveButtonText =
            if isEditing then
                "Update Article"
            else
                "Publish Article"
    in
    Html.form [ onSubmit Save ]
        [ fieldset []
            [ Form.input
                [ class "form-control-lg"
                , placeholder "Article Title"
                , onInput SetTitle
                , defaultValue model.title
                ]
                []
            , Form.input
                [ placeholder "What's this article about?"
                , onInput SetDescription
                , defaultValue model.description
                ]
                []
            , Form.textarea
                [ placeholder "Write your article (in markdown)"
                , attribute "rows" "8"
                , onInput SetBody
                , defaultValue model.body
                ]
                []
            , Form.input
                [ placeholder "Enter tags"
                , onInput SetTags
                , defaultValue model.tags
                ]
                []
            , button [ class "btn btn-lg pull-xs-right btn-primary", disabled model.isSaving ]
                [ text saveButtonText ]
            ]
        ]



-- UPDATE --


type Msg
    = Save
    | SetTitle String
    | SetDescription String
    | SetTags String
    | SetBody String
    | CreateCompleted (Result Http.Error (Article Body))
    | EditCompleted (Result Http.Error (Article Body))


update : User -> Msg -> Model -> ( Model, Cmd Msg )
update user msg model =
    case msg of
        Save ->
            case validate modelValidator model of
                [] ->
                    case model.editingArticle of
                        Nothing ->
                            case Parser.run Tag.listParser model.tags of
                                Ok tags ->
                                    let
                                        request =
                                            Request.Article.create
                                                { tags = tags
                                                , title = model.title
                                                , body = model.body
                                                , description = model.description
                                                }
                                                user.token
                                    in
                                    request
                                        |> Http.send CreateCompleted
                                        |> pair { model | errors = [], isSaving = True }

                                Err _ ->
                                    ( { model | errors = [ ( Tags, "Invalid tags." ) ] }, Cmd.none )

                        Just slug ->
                            user.token
                                |> Request.Article.update slug model
                                |> Http.send EditCompleted
                                |> pair { model | errors = [], isSaving = True }

                errors ->
                    ( { model | errors = errors }, Cmd.none )

        SetTitle title ->
            ( { model | title = title }, Cmd.none )

        SetDescription description ->
            ( { model | description = description }, Cmd.none )

        SetTags tags ->
            ( { model | tags = tags }, Cmd.none )

        SetBody body ->
            ( { model | body = body }, Cmd.none )

        CreateCompleted (Ok article) ->
            Route.Article article.slug
                |> Route.modifyUrl
                |> pair model

        CreateCompleted (Err error) ->
            let
                _ =
                    Debug.log "err" error
            in
            ( { model
                | errors = model.errors ++ [ ( Form, "Server error while attempting to publish article" ) ]
                , isSaving = False
              }
            , Cmd.none
            )

        EditCompleted (Ok article) ->
            Route.Article article.slug
                |> Route.modifyUrl
                |> pair model

        EditCompleted (Err error) ->
            ( { model
                | errors = model.errors ++ [ ( Form, "Server error while attempting to save article" ) ]
                , isSaving = False
              }
            , Cmd.none
            )



-- VALIDATION --


type Field
    = Form
    | Title
    | Body
    | Tags


type alias Error =
    ( Field, String )


modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifBlank .title ( Title, "title can't be blank." )
        , ifBlank .body ( Body, "body can't be blank." )
        ]



-- INTERNAL --


redirectToArticle : Article.Slug -> Cmd msg
redirectToArticle =
    Route.modifyUrl << Route.Article
