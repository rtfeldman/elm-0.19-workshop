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
              ({- TODO: what goes here? -})
    , test "they can decode responses with results in them"
        <| let
            response =
              """{ "items": [
                      /* TODO: dummy JSON goes here */
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
