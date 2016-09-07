port module Main exposing (..)

import ElmHub exposing (..)
import Html.App as Html
import Json.Decode


main : Program Never
main =
    Html.program
        { view = view
        , update = update
        , init = init
        , subscriptions = \_ -> githubResponse decodeResponse
        }


decodeResponse : Json.Decode.Value -> Msg
decodeResponse json =
    case Json.Decode.decodeValue responseDecoder json of
        Err err ->
            HandleSearchError (Just err)

        Ok results ->
            HandleSearchResponse results


port githubResponse : (Json.Decode.Value -> msg) -> Sub msg
