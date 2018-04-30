module Tests exposing (..)

import Time
import Http exposing (Request)
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (Test, test, describe)
import Expect
import HttpBuilder exposing (..)
import Native.Polyfills


polyfillsEnabled : Bool
polyfillsEnabled =
    Native.Polyfills.enabled


testDecoder : Decode.Decoder String
testDecoder =
    Decode.at [ "hello" ] Decode.string


alwaysEmptyOk : a -> Result x ()
alwaysEmptyOk _ =
    Ok ()


expectNothing : Http.Expect ()
expectNothing =
    Http.expectStringResponse alwaysEmptyOk


defaultBuilder : RequestBuilder ()
defaultBuilder =
    { method = "POST"
    , url = "example.com"
    , expect = expectNothing
    , timeout = Nothing
    , withCredentials = False
    , headers = []
    , body = Http.emptyBody
    , queryParams = []
    , cacheBuster = Nothing
    }


all : Test
all =
    describe "HttpBuilder"
        [ test "polyfills are set up" <|
            \() -> polyfillsEnabled |> Expect.equal True
        , test "Request Building" <|
            \() ->
                let
                    actual =
                        get "http://example.com"
                            |> withBearerToken "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhIjoiYSJ9.MvhYYpYBuN1rUaV0GGnQGvr889zY0xSc20Lnt8nMTfE"
                            |> withHeader "Test" "Header"
                            |> withHeaders [ ( "OtherTest", "Header" ) ]
                            |> withStringBody "text/plain" """{ "test": "body" }"""
                            |> withTimeout (10 * Time.second)
                            |> withCredentials
                            |> withQueryParams [ ( "hello", "world" ) ]
                            |> withCacheBuster "cb"
                            |> withExpect expectNothing

                    expected =
                        { method = "GET"
                        , url = "http://example.com"
                        , queryParams = [ ( "hello", "world" ) ]
                        , body = Http.stringBody "text/plain" """{ "test": "body" }"""
                        , timeout = Just (10 * Time.second)
                        , expect = expectNothing
                        , withCredentials = True
                        , headers =
                            [ Http.header "OtherTest" "Header"
                            , Http.header "Test" "Header"
                            , Http.header "Authorization" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhIjoiYSJ9.MvhYYpYBuN1rUaV0GGnQGvr889zY0xSc20Lnt8nMTfE"
                            ]
                        , cacheBuster = Just "cb"
                        }
                in
                    Expect.equal expected actual
        , describe "with*Body functions"
            [ test "withStringBody applies string directly" <|
                \() ->
                    post "example.com"
                        |> withStringBody "text/plain" "hello"
                        |> withExpect expectNothing
                        |> Expect.equal { defaultBuilder | body = Http.stringBody "text/plain" "hello" }
            , test "withJsonBody applies a Json.Value as a string" <|
                \() ->
                    post "example.com"
                        |> withJsonBody (Encode.string "hello")
                        |> withExpect expectNothing
                        |> Expect.equal { defaultBuilder | body = Http.jsonBody (Encode.string "hello") }
            , test "withUrlEncodedBody encodes pairs as url components" <|
                \() ->
                    post "example.com"
                        |> withUrlEncodedBody [ ( "hello", "w orld" ) ]
                        |> withExpect expectNothing
                        |> Expect.equal { defaultBuilder | body = Http.stringBody "application/x-www-form-urlencoded" "hello=w+orld" }
            , test "withMultipartStringBody passes through to Http.multipart" <|
                \() ->
                    post "example.com"
                        |> withMultipartStringBody [ ( "hello", "world" ) ]
                        |> withExpect expectNothing
                        |> Expect.equal { defaultBuilder | body = Http.multipartBody [ Http.stringPart "hello" "world" ] }
            ]
        ]
