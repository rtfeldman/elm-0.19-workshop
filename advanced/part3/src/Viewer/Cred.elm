module Viewer.Cred exposing (Cred, addHeader, addHeaderIfAvailable, decoder, encodeToken)

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Username exposing (Username)



-- TYPES


type alias Cred =
    { username : Username
    , token : String
    }



-- SERIALIZATION


decoder : Decoder Cred
decoder =
    Decode.succeed Cred
        |> required "username" Username.decoder
        |> required "token" Decode.string



-- TRANSFORM


encodeToken : Cred -> Value
encodeToken cred =
    Encode.string cred.token


addHeader : Cred -> RequestBuilder a -> RequestBuilder a
addHeader cred builder =
    builder
        |> withHeader "authorization" ("Token " ++ cred.token)


addHeaderIfAvailable : Maybe Cred -> RequestBuilder a -> RequestBuilder a
addHeaderIfAvailable maybeCred builder =
    case maybeCred of
        Just cred ->
            addHeader cred builder

        Nothing ->
            builder
