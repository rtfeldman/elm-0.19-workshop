module Avatar exposing (Avatar, decoder, encode, src, toMaybeString)

import Html exposing (Attribute)
import Html.Attributes
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- TYPES


type Avatar
    = Avatar (Maybe String)



-- CREATE


decoder : Decoder Avatar
decoder =
    Decode.map Avatar (Decode.nullable Decode.string)



-- TRANSFORM


encode : Avatar -> Value
encode (Avatar maybeUrl) =
    maybeUrl
        |> Maybe.map Encode.string
        |> Maybe.withDefault Encode.null


src : Avatar -> Attribute msg
src avatar =
    Html.Attributes.src (avatarToUrl avatar)


toMaybeString : Avatar -> Maybe String
toMaybeString (Avatar maybeUrl) =
    maybeUrl



-- INTERNAL


avatarToUrl : Avatar -> String
avatarToUrl (Avatar maybeUrl) =
    case maybeUrl of
        Nothing ->
            defaultPhotoUrl

        Just "" ->
            defaultPhotoUrl

        Just url ->
            url


defaultPhotoUrl : String
defaultPhotoUrl =
    "http://localhost:3000/images/smiley-cyrus.jpg"
