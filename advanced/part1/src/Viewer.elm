module Viewer exposing (Viewer, cred, decoder, email, encode, minPasswordChars, profile)

{-| The logged-in user currently viewing this page.
-}

import Avatar exposing (Avatar)
import Email exposing (Email)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode exposing (Value)
import Profile exposing (Profile)
import Username exposing (Username)
import Viewer.Cred as Cred exposing (Cred)



-- TYPES


type Viewer
    = Viewer Internals


type alias Internals =
    { cred : Cred
    , profile : Profile
    , email : Email
    }



-- INFO


cred : Viewer -> Cred
cred (Viewer info) =
    info.cred


profile : Viewer -> Profile
profile (Viewer info) =
    info.profile


email : Viewer -> Email
email (Viewer info) =
    info.email


{-| Passwords must be at least this many characters long!
-}
minPasswordChars : Int
minPasswordChars =
    6



-- SERIALIZATION


encode : Viewer -> Value
encode (Viewer info) =
    Encode.object
        [ ( "email", Email.encode info.email )
        , ( "username", Username.encode info.cred.username )
        , ( "image", Avatar.encode (Profile.avatar info.profile) )
        , ( "token", Cred.encodeToken info.cred )
        , ( "bio"
          , case Profile.bio info.profile of
                Just bio ->
                    Encode.string bio

                Nothing ->
                    Encode.null
          )
        ]


decoder : Decoder Viewer
decoder =
    Decode.succeed Internals
        |> custom Cred.decoder
        |> custom Profile.decoder
        |> required "email" Email.decoder
        |> Decode.map Viewer
