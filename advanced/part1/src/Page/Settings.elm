module Page.Settings exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api exposing (optionalError)
import Avatar
import Browser.Navigation as Nav
import Email exposing (Email)
import Html exposing (Html, button, div, fieldset, h1, input, li, text, textarea, ul)
import Html.Attributes exposing (attribute, class, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import HttpBuilder
import Json.Decode as Decode exposing (Decoder, decodeString, field, list, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import Profile exposing (Profile)
import Route
import Session exposing (Session)
import Username as Username exposing (Username)
import Validate exposing (Valid, Validator, fromValid, ifBlank, validate)
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)



-- MODEL


type alias Model =
    { session : Session
    , errors : List Error
    , form : Form
    }


type alias Form =
    { avatar : Maybe String
    , bio : String
    , email : String
    , username : String
    , password : Maybe String
    }


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , errors = []
      , form =
            case Session.viewer session of
                Just viewer ->
                    let
                        profile =
                            Viewer.profile viewer

                        cred =
                            Viewer.cred viewer
                    in
                    { avatar = Avatar.toMaybeString (Profile.avatar profile)
                    , email = Email.toString (Viewer.email viewer)
                    , bio = Maybe.withDefault "" (Profile.bio profile)
                    , username = Username.toString cred.username
                    , password = Nothing
                    }

                Nothing ->
                    -- It's fine to store a blank form here. You won't be
                    -- able to submit it if you're not logged in anyway.
                    { avatar = Nothing
                    , email = ""
                    , bio = ""
                    , username = ""
                    , password = Nothing
                    }
      }
    , Cmd.none
    )


{-| A form that has been validated. Only the `edit` function uses this. Its
purpose is to prevent us from forgetting to validate the form before passing
it to `edit`.

This doesn't create any guarantees that the form was actually validated. If
we wanted to do that, we'd need to move the form data into a separate module!

-}
type ValidForm
    = Valid Form



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Settings"
    , content =
        case Session.cred model.session of
            Just cred ->
                div [ class "settings-page" ]
                    [ div [ class "container page" ]
                        [ div [ class "row" ]
                            [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                                [ h1 [ class "text-xs-center" ] [ text "Your Settings" ]
                                , model.errors
                                    |> List.map (\( _, error ) -> li [] [ text error ])
                                    |> ul [ class "error-messages" ]
                                , viewForm cred model.form
                                ]
                            ]
                        ]
                    ]

            Nothing ->
                text "Sign in to view your settings."
    }


viewForm : Cred -> Form -> Html Msg
viewForm cred form =
    Html.form [ onSubmit (SubmittedForm cred) ]
        [ fieldset []
            [ fieldset [ class "form-group" ]
                [ input
                    [ class "form-control"
                    , placeholder "URL of profile picture"
                    , value (Maybe.withDefault "" form.avatar)
                    , onInput EnteredImage
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ input
                    [ class "form-control form-control-lg"
                    , placeholder "Username"
                    , value form.username
                    , onInput EnteredUsername
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ textarea
                    [ class "form-control form-control-lg"
                    , placeholder "Short bio about you"
                    , attribute "rows" "8"
                    , value form.bio
                    , onInput EnteredBio
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ input
                    [ class "form-control form-control-lg"
                    , placeholder "Email"
                    , value form.email
                    , onInput EnteredEmail
                    ]
                    []
                ]
            , fieldset [ class "form-group" ]
                [ input
                    [ class "form-control form-control-lg"
                    , type_ "password"
                    , placeholder "Password"
                    , value (Maybe.withDefault "" form.password)
                    , onInput EnteredPassword
                    ]
                    []
                ]
            , button
                [ class "btn btn-lg btn-primary pull-xs-right" ]
                [ text "Update Settings" ]
            ]
        ]



-- UPDATE


type Msg
    = SubmittedForm Cred
    | EnteredEmail String
    | EnteredUsername String
    | EnteredPassword String
    | EnteredBio String
    | EnteredImage String
    | CompletedSave (Result Http.Error Viewer)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm cred ->
            case validate formValidator model.form of
                Ok validForm ->
                    ( { model | errors = [] }
                    , edit cred validForm
                        |> Http.send CompletedSave
                    )

                Err errors ->
                    ( { model | errors = errors }
                    , Cmd.none
                    )

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredUsername username ->
            updateForm (\form -> { form | username = username }) model

        EnteredPassword passwordStr ->
            let
                password =
                    if String.isEmpty passwordStr then
                        Nothing

                    else
                        Just passwordStr
            in
            updateForm (\form -> { form | password = password }) model

        EnteredBio bio ->
            updateForm (\form -> { form | bio = bio }) model

        EnteredImage avatarStr ->
            let
                avatar =
                    if String.isEmpty avatarStr then
                        Nothing

                    else
                        Just avatarStr
            in
            updateForm (\form -> { form | avatar = avatar }) model

        CompletedSave (Err error) ->
            let
                serverErrors =
                    error
                        |> Api.listErrors errorsDecoder
                        |> List.map (\errorMessage -> ( Server, errorMessage ))
            in
            ( { model | errors = List.append model.errors serverErrors }
            , Cmd.none
            )

        CompletedSave (Ok cred) ->
            ( model
            , Session.login cred
            )

        GotSession session ->
            ( { model | session = session }, Cmd.none )


{-| Helper function for `update`. Updates the form and returns Cmd.none and
Ignored. Useful for recording form fields!
-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session



-- VALIDATION


type ErrorSource
    = Server
    | Username
    | Email
    | Password
    | ImageUrl
    | Bio


type alias Error =
    ( ErrorSource, String )


formValidator : Validator Error Form
formValidator =
    Validate.all
        [ ifBlank .username ( Username, "username can't be blank." )
        , ifBlank .email ( Email, "email can't be blank." )
        ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    Decode.succeed (\email username password -> List.concat [ email, username, password ])
        |> optionalError "email"
        |> optionalError "username"
        |> optionalError "password"



-- HTTP


{-| This takes a Valid Form as a reminder that it needs to have been validated
first.
-}
edit : Cred -> Valid Form -> Http.Request Viewer
edit cred validForm =
    let
        form =
            fromValid validForm

        updates =
            [ Just ( "username", Encode.string form.username )
            , Just ( "email", Encode.string form.email )
            , Just ( "bio", Encode.string form.bio )
            , Just ( "image", Maybe.withDefault Encode.null (Maybe.map Encode.string form.avatar) )
            , Maybe.map (\pass -> ( "password", Encode.string pass )) form.password
            ]
                |> List.filterMap identity

        body =
            ( "user", Encode.object updates )
                |> List.singleton
                |> Encode.object
                |> Http.jsonBody

        expect =
            Decode.field "user" Viewer.decoder
                |> Http.expectJson
    in
    Api.url [ "user" ]
        |> HttpBuilder.put
        |> HttpBuilder.withExpect expect
        |> HttpBuilder.withBody body
        |> Cred.addHeader cred
        |> HttpBuilder.toRequest
