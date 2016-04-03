module Tests (..) where

import ElmTest exposing (..)
import ElmHub exposing (responseDecoder)
import Json.Decode exposing (decodeString)


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
              (decodeString responseDecoder emptyResponse)
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
              (decodeString responseDecoder response)
              (Ok
                [ { id = 5, name = "foo", stars = 42 }
                , { id = 3, name = "bar", stars = 77 }
                ]
              )
    ]
