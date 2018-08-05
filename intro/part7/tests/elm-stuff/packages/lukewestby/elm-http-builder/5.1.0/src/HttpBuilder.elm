module HttpBuilder
    exposing
        ( RequestBuilder
        , get
        , post
        , put
        , patch
        , delete
        , options
        , trace
        , head
        , withHeader
        , withHeaders
        , withBody
        , withStringBody
        , withJsonBody
        , withMultipartStringBody
        , withUrlEncodedBody
        , withTimeout
        , withCredentials
        , withQueryParams
        , withExpect
        , withCacheBuster
        , toRequest
        , toTask
        , send
        )

{-| Extra helpers for more easily building Http requests that require greater
configuration than what is provided by `elm-http` out of the box.

# Start a request
@docs RequestBuilder, get, post, put, patch, delete, options, trace, head

# Configure request properties
@docs withHeader, withHeaders, withBody, withStringBody, withJsonBody, withMultipartStringBody, withUrlEncodedBody, withTimeout, withCredentials, withQueryParams, withExpect, withCacheBuster

# Make the request
@docs toRequest, toTask, send
-}

-- where

import String
import Task exposing (Task)
import Maybe exposing (Maybe(..))
import Time exposing (Time)
import Json.Encode as Encode
import Result exposing (Result(Ok, Err))
import Http


{-| A type for chaining request configuration
-}
type alias RequestBuilder a =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect a
    , timeout : Maybe Time
    , withCredentials : Bool
    , queryParams : List ( String, String )
    , cacheBuster : Maybe String
    }


requestWithMethodAndUrl : String -> String -> RequestBuilder ()
requestWithMethodAndUrl method url =
    { method = method
    , url = url
    , headers = []
    , body = Http.emptyBody
    , expect = Http.expectStringResponse (\_ -> Ok ())
    , timeout = Nothing
    , withCredentials = False
    , queryParams = []
    , cacheBuster = Nothing
    }


{-| Start building a GET request with a given URL

    get "https://example.com/api/items/1"
-}
get : String -> RequestBuilder ()
get =
    requestWithMethodAndUrl "GET"


{-| Start building a POST request with a given URL

    post "https://example.com/api/items"
-}
post : String -> RequestBuilder ()
post =
    requestWithMethodAndUrl "POST"


{-| Start building a PUT request with a given URL

    put "https://example.com/api/items/1"
-}
put : String -> RequestBuilder ()
put =
    requestWithMethodAndUrl "PUT"


{-| Start building a PATCH request with a given URL

    patch "https://example.com/api/items/1"
-}
patch : String -> RequestBuilder ()
patch =
    requestWithMethodAndUrl "PATCH"


{-| Start building a DELETE request with a given URL

    delete "https://example.com/api/items/1"
-}
delete : String -> RequestBuilder ()
delete =
    requestWithMethodAndUrl "DELETE"


{-| Start building a OPTIONS request with a given URL

    options "https://example.com/api/items/1"
-}
options : String -> RequestBuilder ()
options =
    requestWithMethodAndUrl "OPTIONS"


{-| Start building a TRACE request with a given URL

    trace "https://example.com/api/items/1"
-}
trace : String -> RequestBuilder ()
trace =
    requestWithMethodAndUrl "TRACE"


{-| Start building a HEAD request with a given URL

    head "https://example.com/api/items/1"
-}
head : String -> RequestBuilder ()
head =
    requestWithMethodAndUrl "HEAD"


{-| Add a single header to a request

    get "https://example.com/api/items/1"
        |> withHeader "Content-Type" "application/json"
-}
withHeader : String -> String -> RequestBuilder a -> RequestBuilder a
withHeader key value builder =
    { builder | headers = (Http.header key value) :: builder.headers }


{-| Add many headers to a request

    get "https://example.com/api/items/1"
        |> withHeaders [("Content-Type", "application/json"), ("Accept", "application/json")]
-}
withHeaders : List ( String, String ) -> RequestBuilder a -> RequestBuilder a
withHeaders headerPairs builder =
    { builder
        | headers = (List.map (uncurry Http.header) headerPairs) ++ builder.headers
    }


{-| Add an Http.Body to the request
    post "https://example.com/api/save-text"
        |> withBody (Http.stringBody "text/plain" "Hello!")
-}
withBody : Http.Body -> RequestBuilder a -> RequestBuilder a
withBody body builder =
    { builder | body = body }


{-| Convenience function for adding a string body to a request

    post "https://example.com/api/items/1"
        |> withStringBody "application/json" """{ "sortBy": "coolness", "take": 10 }"""
-}
withStringBody : String -> String -> RequestBuilder a -> RequestBuilder a
withStringBody contentType value =
    withBody <| Http.stringBody contentType value


{-| Convenience function for adding a JSON body to a request

    params = Json.Encode.object
        [ ("sortBy", Json.Encode.string "coolness")
        , ("take", Json.Encode.int 10)
        ]

    post "https://example.com/api/items/1"
        |> withJsonBody params
-}
withJsonBody : Encode.Value -> RequestBuilder a -> RequestBuilder a
withJsonBody value =
    withBody <| Http.jsonBody value


{-| Convenience function for adding multipart bodies composed of String, String
key-value pairs. Since `Http.stringData` is currently the only `Http.Data`
creator having this function removes the need to use the `Http.Data` type in
your type signatures.

    post "https://example.com/api/items/1"
        |> withMultipartStringBody [("user", JS.encode user)]
-}
withMultipartStringBody : List ( String, String ) -> RequestBuilder a -> RequestBuilder a
withMultipartStringBody partPairs =
    withBody <| Http.multipartBody <| List.map (uncurry Http.stringPart) partPairs


{-| Convenience function for adding url encoded bodies

    post "https://example.com/api/whatever"
        |> withUrlEncodedBody [("user", "Luke"), ("pwd", "secret")]
-}
withUrlEncodedBody : List ( String, String ) -> RequestBuilder a -> RequestBuilder a
withUrlEncodedBody =
    joinUrlEncoded >> withStringBody "application/x-www-form-urlencoded"


{-| Set the `timeout` setting on the request

    get "https://example.com/api/items/1"
        |> withTimeout (10 * Time.second)
-}
withTimeout : Time -> RequestBuilder a -> RequestBuilder a
withTimeout timeout builder =
    { builder | timeout = Just timeout }


{-| Set the `withCredentials` flag on the request to True. Works via
[`XMLHttpRequest#withCredentials`](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/withCredentials)

    get "https://example.com/api/items/1"
        |> withCredentials
-}
withCredentials : RequestBuilder a -> RequestBuilder a
withCredentials builder =
    { builder | withCredentials = True }


{-| Choose an `Expect` for the request

    get "https://example.com/api/items/1"
        |> withExpect (Http.expectJson itemsDecoder)
-}
withExpect : Http.Expect b -> RequestBuilder a -> RequestBuilder b
withExpect expect builder =
    { builder | expect = expect }


{-| Add some query params to the url for the request

    get "https://example.com/api/items/1"
        |> withQueryParams [("hello", "world"), ("foo", "bar")]
        |> withQueryParams [("baz", "qux")]
    -- sends a request to https://example.com/api/items/1?hello=world&foo=bar&baz=qux
-}
withQueryParams : List ( String, String ) -> RequestBuilder a -> RequestBuilder a
withQueryParams queryParams builder =
    { builder | queryParams = builder.queryParams ++ queryParams }


{-| Send the request with a Time based cache buster added to the URL.
You provide a key for an extra query param, and when the request is sent that
query param will be given a value with the current timestamp.

    type Msg
        = Items (Result Http.Error String)

    get "https://example.com/api/items"
        |> withExpect (Http.expectString)
        |> withCacheBuster "cache_buster"
        |> send Items

    -- makes a request to https://example.com/api/items?cache_buster=1481633217383
-}
withCacheBuster : String -> RequestBuilder a -> RequestBuilder a
withCacheBuster paramName builder =
    { builder | cacheBuster = Just paramName }


{-| Extract the Http.Request component of the builder in case you want to use it
directly. **This function is lossy** and will discard some of the extra stuff
that HttpBuilder allows you to do.

Things that will be lost:
- Attaching a cache buster to requests using `withCacheBuster`
-}
toRequest : RequestBuilder a -> Http.Request a
toRequest builder =
    let
        encodedParams =
            joinUrlEncoded builder.queryParams

        fullUrl =
            if String.isEmpty encodedParams then
                builder.url
            else
                builder.url ++ "?" ++ encodedParams
    in
        Http.request
            { method = builder.method
            , url = fullUrl
            , headers = builder.headers
            , body = builder.body
            , expect = builder.expect
            , timeout = builder.timeout
            , withCredentials = builder.withCredentials
            }


{-| Convert the RequestBuilder to a Task with all options applied. `toTask`
differs from `toRequest` in that it retains all extra behavior allowed by
HttpBuilder, including

- Attaching a cache buster to requests using `withCacheBuster`
-}
toTask : RequestBuilder a -> Task Http.Error a
toTask builder =
    case builder.cacheBuster of
        Just paramName ->
            toTaskWithCacheBuster paramName builder

        Nothing ->
            toTaskPlain builder


toTaskPlain : RequestBuilder a -> Task Http.Error a
toTaskPlain builder =
    Http.toTask <| toRequest builder


toTaskWithCacheBuster : String -> RequestBuilder a -> Task Http.Error a
toTaskWithCacheBuster paramName builder =
    let
        request timestamp =
            builder
                |> withQueryParams [ ( paramName, toString timestamp ) ]
                |> toTaskPlain
    in
        Time.now |> Task.andThen request


{-| Send the request
-}
send : (Result Http.Error a -> msg) -> RequestBuilder a -> Cmd msg
send tagger builder =
    builder
        |> toTask
        |> Task.attempt tagger


joinUrlEncoded : List ( String, String ) -> String
joinUrlEncoded args =
    String.join "&" (List.map queryPair args)


queryPair : ( String, String ) -> String
queryPair ( key, value ) =
    queryEscape key ++ "=" ++ queryEscape value


queryEscape : String -> String
queryEscape =
    Http.encodeUri >> replace "%20" "+"


replace : String -> String -> String -> String
replace old new =
    String.split old >> String.join new
