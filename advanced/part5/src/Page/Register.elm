module Page.Register exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api exposing (optionalError)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import Route exposing (Route)
import Session exposing (Session)
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
    { email : String
    , username : String
    , password : String
    }


init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , errors = []
      , form =
            { email = ""
            , username = ""
            , password = ""
            }
      }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Register"
    , content =
        div [ class "cred-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                        [ h1 [ class "text-xs-center" ] [ text "Sign up" ]
                        , p [ class "text-xs-center" ]
                            [ a [ Route.href Route.Login ]
                                [ text "Have an account?" ]
                            ]
                        , model.errors
                            |> List.map (\( _, error ) -> li [] [ text error ])
                            |> ul [ class "error-messages" ]
                        , viewForm model.form
                        ]
                    ]
                ]
            ]
    }


viewForm : Form -> Html Msg
viewForm form =
    Html.form [ onSubmit SubmittedForm ]
        [ fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , placeholder "Username"
                , onInput EnteredUsername
                , value form.username
                ]
                []
            ]
        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , placeholder "Email"
                , onInput EnteredEmail
                , value form.email
                ]
                []
            ]
        , fieldset [ class "form-group" ]
            [ input
                [ class "form-control form-control-lg"
                , type_ "password"
                , placeholder "Password"
                , onInput EnteredPassword
                , value form.password
                ]
                []
            ]
        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Sign up" ]
        ]



-- UPDATE


type Msg
    = SubmittedForm
    | EnteredEmail String
    | EnteredUsername String
    | EnteredPassword String
    | CompletedRegister (Result Http.Error Viewer)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm ->
            case validate formValidator model.form of
                Ok validForm ->
                    ( { model | errors = [] }
                    , Http.send CompletedRegister (register validForm)
                    )

                Err errors ->
                    ( { model | errors = errors }
                    , Cmd.none
                    )

        EnteredUsername username ->
            updateForm (\form -> { form | username = username }) model

        EnteredEmail email ->
            updateForm (\form -> { form | email = email }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        CompletedRegister (Err error) ->
            let
                serverErrors =
                    error
                        |> Api.listErrors errorsDecoder
                        |> List.map (\errorMessage -> ( Server, errorMessage ))
            in
            ( { model | errors = List.append model.errors serverErrors }
            , Cmd.none
            )

        CompletedRegister (Ok cred) ->
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


type alias Error =
    ( ErrorSource, String )


formValidator : Validator Error Form
formValidator =
    Validate.all
        [ ifBlank .username ( Username, "username can't be blank." )
        , ifBlank .email ( Email, "email can't be blank." )
        , Validate.fromErrors passwordLength
        ]


minPasswordChars : Int
minPasswordChars =
    6


passwordLength : Form -> List Error
passwordLength { password } =
    if String.length password < minPasswordChars then
        [ ( Password, "password must be at least " ++ String.fromInt minPasswordChars ++ " characters long." ) ]

    else
        []


errorsDecoder : Decoder (List String)
errorsDecoder =
    Decode.succeed (\email username password -> List.concat [ email, username, password ])
        |> optionalError "email"
        |> optionalError "username"
        |> optionalError "password"



-- HTTP


register : Valid Form -> Http.Request Viewer
register validForm =
    let
        form =
            fromValid validForm

        user =
            Encode.object
                [ ( "username", Encode.string form.username )
                , ( "email", Encode.string form.email )
                , ( "password", Encode.string form.password )
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
    Decode.field "user" Viewer.decoder
        |> Http.post (Api.url [ "users" ]) body
