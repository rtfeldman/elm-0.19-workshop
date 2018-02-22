module Json.Starter
    exposing
        ( Field
        , Json
        , Outcome(..)
        , decodeAll
        , decodeObject
        , errorsToString
        , fromString
        , nullable
        , required
        , toDecoder
        )

{-| Decode JSON values into Elm values.

Let's say we have a `User` type, and some JSON that represents one:

    type alias User =
        { name : String
        , stars : Int
        , email : Maybe String
        , administrator : Bool
        }

    userJSON : String
    userJSON =
        """
        {
          "name": "Sam Sample",
          "num_stars": 5,
          "email": "sam@sample.com",
          "auth_token": "abc93fd3b",
          "is an admin": false,
        }
        """

There are a few differences between the two.

  - The JSON object has an `auth_token` field that we don't care about.
  - The `stars` field in the Elm record is called `num_stars` in the JSON object.
  - The `administrator` field in the Elm record is called `is an admin` in JSON.
  - The `email` field in the Elm record is a `Maybe String`, but JSON doesn't have `Maybe`.

We'll resolve all three of these differences in the course of decoding the JSON.
Heres the function which will do this:

    decodeUser : Json -> Result String User
    decodeUser json =
        case
            decodeObject json
                [ required [ "name" ]
                , nullable [ "email" ]
                , required [ "is an admin" ]
                , required [ "num_stars" ]
                ]
        of
            [ String name, MaybeString email, Bool administrator, Number stars _ ] ->
                Ok
                    { name = name
                    , email = email
                    , administrator = administrator
                    , stars = stars
                    }

            errors ->
                Err (Json.errorsToString errors)

This function takes a `Json` value (we'll see how to get one later) and returns
`Ok` with the resulting `User` if decoding succeeded, and `Err` with an error
message `String` if it failed. Here are some ways decoding could fail:

  - The JSON was malformed
  - One of the expected fields (such as `email`) was missing
  - A value had an unexpected type (for example, `email` was a number)

The call to `decodeObject` specifies which fields we expect, and what their
types should be.

    decodeObject json
        [ required [ "name" ]
        , nullable [ "email" ]
        , required [ "is an admin" ]
        , required [ "num_stars" ]
        ]

This says that we expect the `name`, `email`, `num_stars`, and `is an admin`
fields to be present in the JSON. There may be additional fields present (such
as `auth_token`) but we don't care about them.

The distinction between `required` and `nullable` is that `name`, `num_stars`,
and `is an admin` must not be `null`, but we expect that `email` might be `null`.

Next we have a _case-expression_ with a branch that specifies the types of
values we expect to find in this JSON.

    [ String name, MaybeString email, Bool administrator, Number stars _] ->

The order we use for this list corresponds to the order we specified our
`nullable` and `required` fields earlier. Because we had `required "name"`
first in that list, we have `String name` first in this list, and so on.

Here's what these types do:

  - `String name` confirms that `required "name"` found a string in the JSON, and assigns it to the `name` variable. That `name` variable's type is `String`.
  - `MaybeString email` confirms that `nullable "email"` found either a string or a `null` in the JSON. If it found `null`, it assigns `Nothing` to the `email : Maybe String` variable, and if it found a string, it assigns `Just` that string.
  - `Bool administrator` confirms that `required "is an admin"` found a boolean in the JSON, and assigns it to `administrator : Bool`.
  - `Number stars _` confirms that `required "num_stars"` found a number. Since JSON does not distinguish between integers and floats, `Number` presents both alternatives; use `Number intGoesHere _` to get the integer (with any decimals truncated) and `Nuumber _ floatGoesHere` to get the float. Since we wanted an integer, we used `Number stars _`. If `stars` were a `Float`, we would have used `Number _ stars` instead.

Now that we have the decoded values in Elm variables, we can use them to return
a `User` record.

    [ String name, MaybeString email, Bool administrator, Number stars _ ] ->
        Ok
            { name = name
            , email = email
            , administrator = administrator
            , stars = stars
            }

If anything went wrong - for example, the JSON was malformed, or there was no
`email` field, or `stars` was a string instead of a number - then the other
branch of the _case-expression_ will get run:

    errors ->
        Err (errorsToString errors)

The `errorsToString` function generates an error message string. This message
is for the benefit of programmers, not users (who can't do much with a message
like "this JSON was malformed") - so this string should be used for
behind-the-scenes logging purposes, if at all.


## Nested JSON

Sometimes we need to deal with JSON that has a nested structure. For example,
what if our example JSON had `name` and `email` nested under a `user` field?

    userJSON : String
    userJSON =
        """
        {
          "user": {
            "name": "Sam Sample",
            "email": "sam@sample.com",
          },
          "num_stars": 5,
          "auth_token": "abc93fd3b",
          "is an admin": false,
        }
        """

We can decode this by adding `"user"` before the `"name"` and `"email"` fields:

    decodeObject json
        [ required [ "user", "name" ]
        , nullable [ "user", "email" ]
        , required [ "is an admin" ]
        , required [ "num_stars" ]
        ]

This will use `user.name` for the first value in the list and `user.email` as
the second value. We can add as many of these as we like; for example,
`[ "user", "account", "email" ]` would decode from `user.account.email`.

We can also handle nested JSON by calling `decodeObject` multiple times.
Let's say we had some JSON with a `users` field, which held a JSON array of
objects that fit the pattern of the individual "user" JSON we decoded earlier.

We could write a function which decodes this JSON to a `List User` like so:

    decodeUsers : Json -> Result String (List User)
    decodeUsers json =
        case decodeObject json [ required [ "users" ] ] of
            [ List usersJson ] ->
                decodeAll usersJson decodeUser

            errors ->
                Err (errorsToString errors)

`decodeObject json [ required [ "users" ] ]` looks about the same as what we did
before. The error branch looks identical to the one we wrote last time. The only
difference is that it decodes to a `List` instead of a `String` or `Bool` like
before:

    [ List usersJson ] ->
        decodeAll usersJson decodeUser

This `usersJson` value has the type `List Json`, which means we can use a
function like `decodeUser` to translate it from JSON into an Elm type.

The `decodeAll` function does exactly what we want here: it applies our
`decodeUser` function to each of the `Json` values in `usersJson : List Json`.
If all those decoding operations succeed, we get back an `Ok` with a `List User`
inside. If any of them fail, we instead get back an `Err` with a `String` inside.

Finally, we can get `Json` values in one of two ways. One is directly from
a string, using [`fromString : String -> Json`](#fromString). Another is
by using [`toDecoder`](#toDecoder) which gives us a `Decoder` value that is
commonly used by packages like [`elm-lang/http`](http://package.elm-lang.org/packages/elm-lang/http/latest).


## Upgrading to Decoders

You now know how to turn raw JSON into validated and parsed Elm values.
Congratulations! You're now ready to get started building Elm things that
interact with JSON.

So why is this library called a Starter Kit, anyway?

The [Decoder](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode)
library is what most production applications end up using for their JSON needs.
It's generally more flexible, composable, and concise than this Starter Kit,
but it's not ideal for getting up and running because there are several more
concepts to learn before you can start using it.

Fortunately, you don't need a JSON toolbox with all the trimmings to get up
and running, and having a nice incremental progression is great for learning!
(Not to worry - it's straightforward to upgrade to Decoders once you find
yourself craving something more than what this library gives you.)

Until then, feel free to put it out of your mind and have fun building things!


# JSON

@docs Json, fromString


# Turning JSON into Result

@docs decodeObject, errorsToString
@docs nullable, required
@docs Outcome(..)
@docs Field


# Converting decoders

@docs toDecoder, decodeAll

-}

import Json.Decode as Decode exposing (Decoder)


-- TYPES --


{-| A JSON string, or a value from JavaScript (which has the same structure as
JSON - for example, an event object).
-}
type Json
    = JsonString String
    | JsonValue Decode.Value


{-| The outcome from decoding a [`Json`](#Json) value.

[`decodeObject`](#decodeObject) returns one of these.

-}
type Outcome
    = String String
    | MaybeString (Maybe String)
    | Number Int Float
    | MaybeNumber (Maybe Int) (Maybe Float)
    | Bool Bool
    | MaybeBool (Maybe Bool)
    | Object Json
    | MaybeObject (Maybe Json)
    | List (List Json)
    | MaybeList (Maybe (List Json))
    | DecodingError String


{-| A field in a [`Json`](#Json) object.
-}
type Field
    = Required (List String)
    | Optional (List String)



-- PUBLIC FUNCTIONS --


{-| Convert a JSON string to a [`Json`](#Json) value.
-}
fromString : String -> Json
fromString str =
    JsonString str


{-| A required field in a [`Json`](#Json) object.
-}
required : List String -> Field
required =
    Required


{-| A field in a [`Json`](#Json) object that can potentially
be `null`. This works like [`required`](#required), except
the result will be a [`Maybe`](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Maybe).
-}
nullable : List String -> Field
nullable =
    Optional


{-| Decode some fields from an object. If the object has more fields than the
requested ones, they will be ignored.
-}
decodeObject : Json -> List Field -> List Outcome
decodeObject json fields =
    case List.foldr (decodeField json) (Ok []) fields of
        Ok outcomes ->
            outcomes

        Err errors ->
            errors


{-| Run a `(Json -> Result)` function on each `Json` value in a list. If they
all return `Ok`, then return `Ok` with a list of those values. If any of them
returns `Err`, return `Err`.

From the example in this module's introduction:

    decodeUsers : Json -> Result String (List User)
    decodeUsers json =
        case decodeObject json [ required [ "users" ] ] of
            [ List usersJson ] ->
                decodeAll usersJson decodeUser

            errors ->
                Err (errorsToString errors)

-}
decodeAll : List Json -> (Json -> Result String a) -> Result String (List a)
decodeAll values decodeFn =
    case List.foldr (decodeAllHelp decodeFn) (Ok []) values of
        Ok decodedValues ->
            Ok decodedValues

        Err errors ->
            Err (String.join "\n\n" errors)


decodeAllHelp :
    (Json -> Result String a)
    -> Json
    -> Result (List String) (List a)
    -> Result (List String) (List a)
decodeAllHelp decodeFn json result =
    case ( result, decodeFn json ) of
        ( Ok values, Ok value ) ->
            Ok (value :: values)

        ( (Err _) as outcomes, Ok _ ) ->
            outcomes

        ( Ok outcomes, Err err ) ->
            Err [ err ]

        ( Err errors, Err err ) ->
            Err (err :: errors)


{-| Create a `Decoder` from a `(Json -> Result)` function.

One place this is useful is with the [`elm-lang/http`](http://package.elm-lang.org/packages/elm-lang/http)
library, which works with `Decoder` values.

    httpRequest : Http.Request User
    httpRequest =
        Http.get "http://example.com/user" (toDecoder decodeUser)


    -- See the decodeObject documentation for an example of
    -- how to implement a function like this:

    decodeUser : Json -> Result String User

-}
toDecoder : (Json -> Result String a) -> Decoder a
toDecoder toResult =
    let
        resolve json =
            case toResult (JsonValue json) of
                Ok val ->
                    Decode.succeed val

                Err err ->
                    Decode.fail err
    in
    Decode.value
        |> Decode.andThen resolve


{-| Returns a string describing any errors that resulted
from decoding a [`Json`](#Json) value.
-}
errorsToString : List Outcome -> String
errorsToString errors =
    -- TODO handle the case where there are no DecodingError values in the list
    List.filterMap errorToMaybeString errors
        |> String.join "\n\n"



-- INTERNAL HELPERS --


errorToMaybeString : Outcome -> Maybe String
errorToMaybeString error =
    case error of
        DecodingError str ->
            Just str

        _ ->
            Nothing


decodeField :
    Json
    -> Field
    -> Result (List Outcome) (List Outcome)
    -> Result (List Outcome) (List Outcome)
decodeField json field result =
    let
        decoder =
            case field of
                Required path ->
                    Decode.at path outcomeDecoder

                Optional path ->
                    Decode.at path maybeOutcomeDecoder
    in
    case ( result, decodeFromDecoder decoder json ) of
        ( Ok outcomes, Ok outcome ) ->
            Ok (outcome :: outcomes)

        ( (Err _) as outcomes, Ok _ ) ->
            outcomes

        ( Ok outcomes, Err err ) ->
            Err [ DecodingError err ]

        ( Err errors, Err err ) ->
            Err (DecodingError err :: errors)


decodeFromDecoder : Decoder a -> Json -> Result String a
decodeFromDecoder decoder json =
    case json of
        JsonString str ->
            Decode.decodeString decoder str

        JsonValue val ->
            Decode.decodeValue decoder val


outcomeDecoder : Decoder Outcome
outcomeDecoder =
    Decode.oneOf
        [ Decode.map String Decode.string
        , Decode.map Bool Decode.bool
        , Decode.map numberFromTuple numberDecoder
        , Decode.map List (Decode.list jsonDecoder)
        , Decode.map Object jsonDecoder
        ]


numberFromTuple : ( Int, Float ) -> Outcome
numberFromTuple ( int, float ) =
    Number int float


maybeNumberFromTuple : Maybe ( Int, Float ) -> Outcome
maybeNumberFromTuple tuple =
    case tuple of
        Just ( int, float ) ->
            MaybeNumber (Just int) (Just float)

        Nothing ->
            MaybeNumber Nothing Nothing


numberDecoder : Decoder ( Int, Float )
numberDecoder =
    Decode.float
        |> Decode.map (\num -> ( truncate num, num ))


maybeOutcomeDecoder : Decoder Outcome
maybeOutcomeDecoder =
    Decode.oneOf
        [ Decode.map MaybeString (Decode.nullable Decode.string)
        , Decode.map MaybeBool (Decode.nullable Decode.bool)
        , Decode.map maybeNumberFromTuple (Decode.nullable numberDecoder)
        , Decode.map MaybeList (Decode.nullable (Decode.list jsonDecoder))
        , Decode.map MaybeObject (Decode.nullable jsonDecoder)
        ]


jsonDecoder : Decoder Json
jsonDecoder =
    Decode.map JsonValue Decode.value
