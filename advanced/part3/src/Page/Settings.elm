module Page.Settings exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api
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
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)



-- MODEL


type alias Model =
    { session : Session
    , problems : List Problem
    , form : Form
    }


type alias Form =
    { avatar : String
    , bio : String
    , email : String
    , username : String
    , password : String
    }


type Problem
    = InvalidEntry ValidatedField String
    | ServerError String


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , problems = []
      , form =
            case Session.viewer session of
                Just viewer ->
                    let
                        profile =
                            Viewer.profile viewer

                        cred =
                            Viewer.cred viewer
                    in
                    { avatar = Maybe.withDefault "" (Avatar.toMaybeString (Profile.avatar profile))
                    , email = Email.toString (Viewer.email viewer)
                    , bio = Maybe.withDefault "" (Profile.bio profile)
                    , username = Username.toString (Cred.username cred)
                    , password = ""
                    }

                Nothing ->
                    -- It's fine to store a blank form here. You won't be
                    -- able to submit it if you're not logged in anyway.
                    { avatar = ""
                    , email = ""
                    , bio = ""
                    , username = ""
                    , password = ""
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
    let
        form =
            viewForm model
    in
    { title = "Settings"
    , content =
        case Session.cred model.session of
            Just cred ->
                div [ class "settings-page" ]
                    [ div [ class "container page" ]
                        [ div [ class "row" ]
                            [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                                [ h1 [ class "text-xs-center" ] [ text "Your Settings" ]
                                , ul [ class "error-messages" ]
                                    (List.map viewProblem model.problems)
                                , form
                                ]
                            ]
                        ]
                    ]

            Nothing ->
                text "Sign in to view your settings."
    }


{-| 👉 TODO refactor this to accept narrower types than the entire Model.
💡 HINT: It may end up with multiple arguments!
-}
viewForm : Model -> Html Msg
viewForm model =
    let
        form =
            model.form
    in
    case Session.cred model.session of
        Nothing ->
            text ""

        Just cred ->
            Html.form [ onSubmit (SubmittedForm cred) ]
                [ fieldset []
                    [ fieldset [ class "form-group" ]
                        [ input
                            [ class "form-control"
                            , placeholder "URL of profile picture"
                            , value form.avatar
                            , onInput EnteredAvatar
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
                            , value form.password
                            , onInput EnteredPassword
                            ]
                            []
                        ]
                    , button
                        [ class "btn btn-lg btn-primary pull-xs-right" ]
                        [ text "Update Settings" ]
                    ]
                ]


viewProblem : Problem -> Html msg
viewProblem problem =
    let
        errorMessage =
            case problem of
                InvalidEntry _ message ->
                    message

                ServerError message ->
                    message
    in
    li [] [ text errorMessage ]



-- UPDATE


type Msg
    = SubmittedForm Cred
    | EnteredEmail String
    | EnteredUsername String
    | EnteredPassword String
    | EnteredBio String
    | EnteredAvatar String
    | CompletedSave (Result Http.Error Viewer)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm cred ->
            case validate model.form of
                Ok validForm ->
                    ( { model | problems = [] }
                    , edit cred validForm
                        |> Http.send CompletedSave
                    )

                Err problems ->
                    ( { model | problems = problems }
                    , Cmd.none
                    )

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredUsername username ->
            updateForm (\form -> { form | username = username }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        EnteredBio bio ->
            updateForm (\form -> { form | bio = bio }) model

        EnteredAvatar avatar ->
            updateForm (\form -> { form | avatar = avatar }) model

        CompletedSave (Err error) ->
            let
                serverErrors =
                    Api.decodeErrors error
                        |> List.map ServerError
            in
            ( { model | problems = List.append model.problems serverErrors }
            , Cmd.none
            )

        CompletedSave (Ok cred) ->
            ( model
            , Session.login cred
            )

        GotSession session ->
            ( { model | session = session }
            , Route.replaceUrl (Session.navKey session) Route.Home
            )


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



-- FORM


{-| Marks that we've trimmed the form's fields, so we don't accidentally send
it to the server without having trimmed it!
-}
type TrimmedForm
    = Trimmed Form


{-| When adding a variant here, add it to `fieldsToValidate` too!

NOTE: there are no ImageUrl or Bio variants here, because they aren't validated!

-}
type ValidatedField
    = Username
    | Email
    | Password


fieldsToValidate : List ValidatedField
fieldsToValidate =
    [ Username
    , Email
    , Password
    ]


{-| Trim the form and validate its fields. If there are problems, report them!
-}
validate : Form -> Result (List Problem) TrimmedForm
validate form =
    let
        trimmedForm =
            trimFields form
    in
    case List.concatMap (validateField trimmedForm) fieldsToValidate of
        [] ->
            Ok trimmedForm

        problems ->
            Err problems


validateField : TrimmedForm -> ValidatedField -> List Problem
validateField (Trimmed form) field =
    List.map (InvalidEntry field) <|
        case field of
            Username ->
                if String.isEmpty form.username then
                    [ "username can't be blank." ]

                else
                    []

            Email ->
                if String.isEmpty form.email then
                    [ "email can't be blank." ]

                else
                    []

            Password ->
                let
                    passwordLength =
                        String.length form.password
                in
                if passwordLength > 0 && passwordLength < Viewer.minPasswordChars then
                    [ "password must be at least " ++ String.fromInt Viewer.minPasswordChars ++ " characters long." ]

                else
                    []


{-| Don't trim while the user is typing! That would be super annoying.
Instead, trim only on submit.
-}
trimFields : Form -> TrimmedForm
trimFields form =
    Trimmed
        { avatar = String.trim form.avatar
        , bio = String.trim form.bio
        , email = String.trim form.email
        , username = String.trim form.username
        , password = String.trim form.password
        }



-- HTTP


{-| This takes a Valid Form as a reminder that it needs to have been validated
first.
-}
edit : Cred -> TrimmedForm -> Http.Request Viewer
edit cred (Trimmed form) =
    let
        encodedAvatar =
            case form.avatar of
                "" ->
                    Encode.null

                avatar ->
                    Encode.string avatar

        updates =
            [ ( "username", Encode.string form.username )
            , ( "email", Encode.string form.email )
            , ( "bio", Encode.string form.bio )
            , ( "image", encodedAvatar )
            ]

        encodedUser =
            Encode.object <|
                case form.password of
                    "" ->
                        updates

                    password ->
                        ( "password", Encode.string password ) :: updates

        body =
            Encode.object [ ( "user", encodedUser ) ]
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


nothingIfEmpty : String -> Maybe String
nothingIfEmpty str =
    if String.isEmpty str then
        Nothing

    else
        Just str
