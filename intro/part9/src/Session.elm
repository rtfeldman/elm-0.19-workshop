port module Session
    exposing
        ( Session
        , changes
        , cred
        , decode
        , login
        , logout
        , navKey
        , viewer
        )

import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode exposing (Value)
import Profile exposing (Profile)
import Time
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)



-- TYPES


type Session
    = LoggedIn Nav.Key Viewer
    | Guest Nav.Key



-- INFO


viewer : Session -> Maybe Viewer
viewer session =
    case session of
        LoggedIn _ val ->
            Just val

        Guest _ ->
            Nothing


cred : Session -> Maybe Cred
cred session =
    case session of
        LoggedIn _ val ->
            Just (Viewer.cred val)

        Guest _ ->
            Nothing


navKey : Session -> Nav.Key
navKey session =
    case session of
        LoggedIn key _ ->
            key

        Guest key ->
            key



-- LOGIN


login : Viewer -> Cmd msg
login newViewer =
    Viewer.encode newViewer
        |> Encode.encode 0
        |> Just
        |> sendSessionToJavaScript



-- LOGOUT


logout : Cmd msg
logout =
    sendSessionToJavaScript Nothing


{-| 👉 TODO 1 of 2: Replace this do-nothing function with a port that sends the
authentication token to JavaScript.

    💡 HINT 1: When you convert it to a port, the port's name _must_ match
    the name JavaScript expects in `intro/server/public/index.html`.
    That name is not `sendSessionToJavaScript`, so you will need to
    rename it to match what JS expects!

    💡 HINT 2: After you rename it, some code in this file will break because
    it was depending on the old name. Follow the compiler errors to fix them!

-}
sendSessionToJavaScript : Maybe String -> Cmd msg
sendSessionToJavaScript maybeAuthenticationToken =
    Cmd.none



-- CHANGES


changes : (Session -> msg) -> Nav.Key -> Sub msg
changes toMsg key =
    receiveSessionFromJavaScript (\val -> toMsg (decode key val))


{-| 👉 TODO 2 of 2: Replace this do-nothing function with a port that receives the
authentication token from JavaScript.

    💡 HINT 1: When you convert it to a port, the port's name _must_ match
    the name JavaScript expects in `intro/server/public/index.html`.
    That name is not `receiveSessionFromJavaScript`, so you will need to
    rename it to match what JS expects!

    💡 HINT 2: After you rename it, some code in this file will break because
    it was depending on the old name. Follow the compiler errors to fix them!

-}
receiveSessionFromJavaScript : (Value -> msg) -> Sub msg
receiveSessionFromJavaScript toMsg =
    Sub.none


decode : Nav.Key -> Value -> Session
decode key value =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    case
        Decode.decodeValue Decode.string value
            |> Result.andThen (Decode.decodeString Viewer.decoder)
            |> Result.toMaybe
    of
        Just decodedViewer ->
            LoggedIn key decodedViewer

        Nothing ->
            Guest key
