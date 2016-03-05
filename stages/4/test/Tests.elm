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
              ({- TODO: put the expected result here instead -})
    , test "they can decode responses with results in them"
        <| let
            response =
              """{
                ... json goes here ...
              }"""

            expected =
              [ { id = 5, name = "foo", stars = 42 }
              , { id = 3, name = "bar", stars = 77 }
              ]
           in
            assertEqual
              (decodeString responseDecoder response)
              ({- TODO: put the expected result here instead -})
    ]
