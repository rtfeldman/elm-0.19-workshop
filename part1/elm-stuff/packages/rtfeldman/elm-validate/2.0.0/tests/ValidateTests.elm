module ValidateTests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Validate


blankness : Test
blankness =
    describe "blankness"
        [ test "empty string is blank" <|
            \() ->
                ""
                    |> Validate.isBlank
                    |> Expect.true "Validate.isBlank should have considered empty string blank"
        , fuzz whitespace "whitespace characters are blank" <|
            \str ->
                str
                    |> Validate.isBlank
                    |> Expect.true "Validate.isBlank should consider whitespace blank"
        , fuzz2 whitespace whitespace "non-whitespace characters mean it's not blank" <|
            \prefix suffix ->
                (prefix ++ "_" ++ suffix)
                    |> Validate.isBlank
                    |> Expect.false "Validate.isBlank shouldn't consider strings containing non-whitespace characters blank"
        ]


email : Test
email =
    describe "email"
        [ test "empty string is not a valid email" <|
            \() ->
                ""
                    |> Validate.isValidEmail
                    |> Expect.false "Validate.isValidEmail should have considered empty string blank"
        , test "valid email is valid" <|
            \() ->
                "foo@bar.com"
                    |> Validate.isValidEmail
                    |> Expect.true "Validate.isValidEmail should have considered foo@bar.com a valid email address"
        ]


whitespace : Fuzzer String
whitespace =
    [ ' ', ' ', '\t', '\n' ]
        |> List.map Fuzz.constant
        |> Fuzz.oneOf
        |> Fuzz.list
        |> Fuzz.map String.fromList
