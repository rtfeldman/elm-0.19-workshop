module Tests (..) where

import ElmTest exposing (..)
import ElmHub exposing (responseDecoder)
import Json.Decode as Decode
import Json.Encode as Encode
import Check exposing (Claim, Evidence, check, claim, that, is, for)
import Check.Producer exposing (..)
import Check.Test exposing (evidenceToTest)
import String
import ElmHub exposing (..)
import Random


all : Test
all =
  suite
    "Decoding responses from GitHub"
    [ test "they can decode empty responses"
        <| let
            emptyResponse =
              """{ "items": [] }"""
           in
            assertEqual
              (Decode.decodeString responseDecoder emptyResponse)
              (Ok [])
    , test "they can decode responses with results in them"
        <| let
            response =
              """{ "items": [
                { "id": 5, "full_name": "foo", "stargazers_count": 42 },
                { "id": 3, "full_name": "bar", "stargazers_count": 77 }
              ] }"""
           in
            assertEqual
              (Decode.decodeString responseDecoder response)
              (Ok
                [ { id = 5, name = "foo", stars = 42 }
                , { id = 3, name = "bar", stars = 77 }
                ]
              )
    , (claim "they can decode individual search results"
        `that` ({- TODO call encodeAndDecode -})
        `is` (\( id, name, stars ) -> Ok (SearchResult id name stars))
        `for` tuple3 ( int, string, int )
      )
        |> check 100 defaultSeed
        |> evidenceToTest
    ]


encodeAndDecode : Int -> String -> Int -> Result String SearchResult
encodeAndDecode id name stars =
  -- TODO: finish turning this into a JSON String,
  -- then Decode it with searchResultDecoder
  [ ( "id", Encode.int id )
  , ( "full_name", Encode.string name )
  , ( "stargazers_count", Encode.int stars )
  ]
    |> Encode.object


defaultSeed =
  Random.initialSeed 42
