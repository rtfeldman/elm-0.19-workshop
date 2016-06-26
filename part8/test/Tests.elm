module Tests exposing (..)

import Test exposing (..)
import Fuzz exposing (..)
import Expect exposing (Expectation)
import ElmHub exposing (responseDecoder)
import Json.Decode exposing (decodeString, Value)
import String


all : Test
all =
    describe "GitHub Response Decoder"
        [ test "it results in an Err for invalid JSON"
            <| \() ->
                let
                    json =
                        """{ "pizza": [] }"""

                    isErrorResult result =
                        -- TODO return True if the given Result is an Err of some sort,
                        -- and False if it is an Ok of some sort.
                        --
                        -- Result docs: http://package.elm-lang.org/packages/elm-lang/core/4.0.1/Result
                        False
                in
                    json
                        |> decodeString responseDecoder
                        |> isErrorResult
                        |> Expect.true "Expected decoding an invalid response to return an Err."
        , test "it successfully decodes a valid response"
            <| \() ->
                """{ "items": [
                    /* TODO: put JSON here! */
                 ] }"""
                    |> decodeString responseDecoder
                    |> Expect.equal
                        (Ok
                            [ { id = 5, name = "foo", stars = 42 }
                            , { id = 3, name = "bar", stars = 77 }
                            ]
                        )
        , test "it decodes one SearchResult for each 'item' in the JSON"
            <| \() ->
                let
                    -- TODO convert this to a fuzz test that generates a random
                    -- list of ids instead of this hardcoded list of three ids.
                    --
                    -- fuzz test docs: http://package.elm-lang.org/packages/project-fuzzball/test/2.0.1/Test#fuzz
                    -- Fuzzer docs: http://package.elm-lang.org/packages/project-fuzzball/test/2.0.1/Fuzz
                    ids =
                        [ 12, 5, 76 ]

                    jsonFromId id =
                        """{"id": """ ++ toString id ++ """, "full_name": "foo", "stargazers_count": 42}"""

                    jsonItems =
                        String.join ", " (List.map jsonFromId ids)

                    json =
                        """{ "items": [""" ++ jsonItems ++ """] }"""
                in
                    case decodeString responseDecoder json of
                        Ok results ->
                            List.length results
                                |> Expect.equal (List.length ids)

                        Err err ->
                            Expect.fail ("JSON decoding failed unexpectedly: " ++ err)
        ]
