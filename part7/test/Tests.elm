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
                                /* TODO: dummy JSON goes here */
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
                        -- TODO return True if the given Result is an Err of some sort,
                        -- and False if it is an Ok of some sort.
                        --
                        -- Result docs: http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Result
                        False
                in
                    Expect.true "Expected decoding an invalid response to return an Err."
                        (isErrorResult (decodeString responseDecoder response))
        ]
        |> Runner.run emit


port emit : ( String, Value ) -> Cmd msg
