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
        |> storeSession



-- LOGOUT


logout : Cmd msg
logout =
    storeSession Nothing


port storeSession : Maybe String -> Cmd msg



-- CHANGES


changes : (Session -> msg) -> Nav.Key -> Sub msg
changes toMsg key =
    onSessionChange (\val -> toMsg (decode key val))


port onSessionChange : (Value -> msg) -> Sub msg


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
