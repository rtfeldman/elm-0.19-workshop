module Api exposing (addServerError, listErrors, optionalError, url)

import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline as Pipeline exposing (optional)
import Url.Builder



-- URL


{-| Get a URL to the Conduit API.
-}
url : List String -> String
url paths =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    Url.Builder.relative ("api" :: paths) []



-- ERRORS


addServerError : List String -> List String
addServerError list =
    "Server error" :: list


{-| Many API endpoints include an "errors" field in their BadStatus responses.
-}
listErrors : Decoder (List String) -> Http.Error -> List String
listErrors decoder error =
    case error of
        Http.BadStatus response ->
            response.body
                |> decodeString (field "errors" decoder)
                |> Result.withDefault [ "Server error" ]

        err ->
            [ "Server error" ]


optionalError : String -> Decoder (List String -> a) -> Decoder a
optionalError fieldName =
    let
        errorToString errorMessage =
            String.join " " [ fieldName, errorMessage ]
    in
    optional fieldName (Decode.list (Decode.map errorToString string)) []
