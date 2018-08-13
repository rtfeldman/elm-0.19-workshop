module Viewer.Cred exposing (Cred, addHeader, addHeaderIfAvailable, decoder, encodeToken, username)

{-| The authentication credentials for the Viewer (that is, the currently logged-in user.)

This includes:

  - The cred's Username
  - The cred's authentication token

By design, there is no way to access the token directly as a String.
It can be encoded for persistence, and it can be added to a header
to a HttpBuilder for a request, but that's it.

This token should never be rendered to the end user, and with this API, it
can't be!

-}

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Username exposing (Username)


{-| The authentication token for the currently logged-in user.

The token records the username associated with this token, which you can ask it for.

By design, there is no way to access the token directly as a String. You can encode it for persistence, and you can add it to a header to a HttpBuilder for a request, but that's it.

-}



-- TYPES


type Cred
    = Cred Username String



-- INFO


username : Cred -> Username
username (Cred val _) =
    val



-- SERIALIZATION


decoder : Decoder Cred
decoder =
    Decode.succeed Cred
        |> required "username" Username.decoder
        |> required "token" Decode.string



-- TRANSFORM


encodeToken : Cred -> Value
encodeToken (Cred _ str) =
    Encode.string str


addHeader : Cred -> RequestBuilder a -> RequestBuilder a
addHeader (Cred _ str) builder =
    builder
        |> withHeader "authorization" ("Token " ++ str)


addHeaderIfAvailable : Maybe Cred -> RequestBuilder a -> RequestBuilder a
addHeaderIfAvailable maybeCred builder =
    case maybeCred of
        Just cred ->
            addHeader cred builder

        Nothing ->
            builder
