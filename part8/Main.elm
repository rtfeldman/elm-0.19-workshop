port module Main exposing (..)

import ElmHub exposing (..)
import Html.App
import Json.Decode


main : Program Never
main =
    Html.App.program
        { view = view
        , update = update githubSearch
        , init = ( initialModel, githubSearch (getQueryString initialModel.query) )
        , subscriptions = \_ -> githubResponse decodeResponse
        }


decodeResponse : Json.Decode.Value -> Msg
decodeResponse json =
    case Json.Decode.decodeValue responseDecoder json of
        Err err ->
            HandleSearchError (Just err)

        Ok results ->
            HandleSearchResponse results


port githubSearch : String -> Cmd msg


port githubResponse : (Json.Decode.Value -> msg) -> Sub msg
