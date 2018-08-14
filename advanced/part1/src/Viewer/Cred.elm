module Viewer.Cred exposing (Cred, addHeader, addHeaderIfAvailable, decoder, encodeToken)

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Username exposing (Username)



-- TYPES


type Cred
    = Cred Username String



-- INFO


username : Cred -> Username
username (Cred uname _) =
    uname



-- SERIALIZATION


decoder : Decoder Cred
decoder =
    Decode.succeed Cred
        |> required "username" Username.decoder
        |> required "token" Decode.string



-- TRANSFORM


encodeToken : Cred -> Value
encodeToken (Cred _ token) =
    Encode.string token


addHeader : Cred -> RequestBuilder a -> RequestBuilder a
addHeader (Cred _ token) builder =
    builder
        |> withHeader "authorization" ("Token " ++ token)


addHeaderIfAvailable : Maybe Cred -> RequestBuilder a -> RequestBuilder a
addHeaderIfAvailable maybeCred builder =
    case maybeCred of
        Just cred ->
            addHeader cred builder

        Nothing ->
            builder
