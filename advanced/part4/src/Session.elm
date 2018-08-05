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
    = Session Internals


type alias Internals =
    { navKey : Nav.Key
    , viewer : Maybe Viewer
    }



-- INFO


viewer : Session -> Maybe Viewer
viewer (Session info) =
    info.viewer


cred : Session -> Maybe Cred
cred (Session info) =
    Maybe.map Viewer.cred info.viewer


navKey : Session -> Nav.Key
navKey (Session info) =
    info.navKey



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
    onSessionChange (decode key)
        |> Sub.map toMsg


port onSessionChange : (Value -> msg) -> Sub msg


decode : Nav.Key -> Value -> Session
decode key value =
    Session
        { viewer = Result.toMaybe (Decode.decodeValue Viewer.decoder value)
        , navKey = key
        }
