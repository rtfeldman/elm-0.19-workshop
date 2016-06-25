port module Main exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import ElmHub exposing (responseDecoder)
import Json.Decode exposing (decodeString, Value)
import Test.Runner.Node as Runner


main : Program Never
main =
    describe "Decoding responses from GitHub"
        [ test "they can decode empty responses"
            <| \() ->
                let
                    emptyResponse =
                        """{ "items": [] }"""
                in
                    Expect.equal (Ok [])
                        (decodeString responseDecoder emptyResponse)
        , test "they can decode responses with results in them"
            <| \() ->
                let
                    response =
                        """{ "items": [
                        { "id": 5, "full_name": "foo", "stargazers_count": 42 },
                        { "id": 3, "full_name": "bar", "stargazers_count": 77 }
                      ] }"""
                in
                    Expect.equal
                        (Ok
                            [ { id = 5, name = "foo", stars = 42 }
                            , { id = 3, name = "bar", stars = 77 }
                            ]
                        )
                        (decodeString responseDecoder response)
        , test "they result in an error for invalid JSON"
            <| \() ->
                let
                    response =
                        """{ "pizza": [] }"""

                    isErrorResult result =
                        case result of
                            Ok _ ->
                                False

                            Err _ ->
                                True
                in
                    Expect.equal True
                        (isErrorResult (decodeString responseDecoder response))
        ]
        |> Runner.run emit


port emit : ( String, Value ) -> Cmd msg
