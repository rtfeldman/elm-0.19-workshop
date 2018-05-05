module Validate
    exposing
        ( Validator
        , all
        , any
        , firstError
        , fromErrors
        , ifBlank
        , ifEmptyDict
        , ifEmptyList
        , ifEmptySet
        , ifFalse
        , ifInvalidEmail
        , ifNotInt
        , ifNothing
        , ifTrue
        , isBlank
        , isInt
        , isValidEmail
        , validate
        )

{-| Convenience functions for validating data.

    import Validate exposing (Validator, ifBlank, ifNotInt, validate)

    type Field = Name | Email | Age

    type alias Model = { name : String, email : String, age : String }

    modelValidator : Validator String Model
    modelValidator =
        Validate.all
            [ ifBlank .name "Please enter a name."
            , Validate.firstError
                [ ifBlank .email "Please enter an email address."
                , ifInvalidEmail .email "This is not a valid email address."
                ]
            , ifNotInt .age "Age must be a whole number."
            ]

    validate modelValidator { name = "Sam", email = "blah", age = "abc" }
        --> [ "This is not a valid email address.", "Age must be a whole number." ]


# Validating a subject

@docs Validator, validate


# Creating validators

@docs ifBlank, ifNotInt, ifEmptyList, ifEmptyDict, ifEmptySet, ifNothing, ifInvalidEmail, ifTrue, ifFalse, fromErrors


# Combining validators

@docs all, any, firstError


# Checking values directly

@docs isBlank, isInt, isValidEmail

-}

import Dict exposing (Dict)
import Regex exposing (Regex)
import Set exposing (Set)
import String


-- VALIDATING A SUBJECT --


{-| A `Validator` contains a function which takes a subject and returns a list
of errors describing anything invalid about that subject.

Pass it to [`validate`](#validate) to get the list of errors.
An empty error list means the subject was valid.

-}
type Validator error subject
    = Validator (subject -> List error)


{-| Return an error if the given predicate returns `True` for the given
subject.

    import Validate exposing (Validator, ifBlank, ifNotInt, validate)

    type Field = Name | Email | Age

    type alias Model = { name : String, email : String, age : String }

    modelValidator : Validator ( Field, String ) Model
    modelValidator =
        Validate.all
            [ ifBlank .name ( Name, "Please enter a name." )
            , ifBlank .email ( Email, "Please enter an email address." )
            , ifNotInt .age ( Age, "Age must be a whole number." )
            ]

    validate modelValidator { name = "Sam", email = "", age = "abc" }
        --> [ ( Email, "Please enter an email address." ), ( Age, "Age must be a whole number." ) ]

-}
validate : Validator error subject -> subject -> List error
validate (Validator getErrors) subject =
    getErrors subject



-- CONSTRUCTING VALIDATORS --


{-| Return an error if the given `String` is empty, or if it contains only
whitespace characters.

    import Validate exposing (Validator, ifBlank)

    modelValidator : Validator Model String
    modelValidator =
        Validate.all
            [ ifBlank .name "Please enter a name."
            , ifBlank .email "Please enter an email address."
            ]

-}
ifBlank : (subject -> String) -> error -> Validator error subject
ifBlank subjectToString error =
    ifTrue (\subject -> isBlank (subjectToString subject)) error


{-| Return an error if the given `String` cannot be parsed as an `Int`.

    import Validate exposing (Validator, ifNotInt)

    modelValidator : Validator Model String
    modelValidator =
        Validate.all
            [ ifNotInt .followers (\_ -> "Please enter a whole number for followers.")
            , ifNotInt .stars (\stars -> "Stars was \"" ++ stars ++ "\", but it needs to be a whole number.")"
            ]

-}
ifNotInt : (subject -> String) -> (String -> error) -> Validator error subject
ifNotInt subjectToString errorFromString =
    let
        getErrors subject =
            let
                str =
                    subjectToString subject
            in
            if isInt str then
                []
            else
                [ errorFromString str ]
    in
    Validator getErrors


{-| Return an error if a `List` is empty.
-}
ifEmptyList : (subject -> List a) -> error -> Validator error subject
ifEmptyList subjectToList error =
    ifTrue (\subject -> List.isEmpty (subjectToList subject)) error


{-| Return an error if a `Dict` is empty.
-}
ifEmptyDict : (subject -> Dict comparable v) -> error -> Validator error subject
ifEmptyDict subjectToDict error =
    ifTrue (\subject -> Dict.isEmpty (subjectToDict subject)) error


{-| Return an error if a `Set` is empty.
-}
ifEmptySet : (subject -> Set comparable) -> error -> Validator error subject
ifEmptySet subjectToSet error =
    ifTrue (\subject -> Set.isEmpty (subjectToSet subject)) error


{-| Return an error if a `Maybe` is `Nothing`.
-}
ifNothing : (subject -> Maybe a) -> error -> Validator error subject
ifNothing subjectToMaybe error =
    ifTrue (\subject -> subjectToMaybe subject == Nothing) error


{-| Return an error if an email address is malformed.

    import Validate exposing (Validator, ifBlank, ifNotInt)

    modelValidator : Validator Model String
    modelValidator =
        Validate.all
            [ ifInvalidEmail .primaryEmail (\_ -> "Please enter a valid primary email address.")
            , ifInvalidEmail .superSecretEmail (\email -> "Unfortunately, \"" ++ email ++ "\" is not a valid Super Secret Email Address.")
            ]

-}
ifInvalidEmail : (subject -> String) -> (String -> error) -> Validator error subject
ifInvalidEmail subjectToEmail errorFromEmail =
    let
        getErrors subject =
            let
                email =
                    subjectToEmail subject
            in
            if isValidEmail email then
                []
            else
                [ errorFromEmail email ]
    in
    Validator getErrors


{-| Create a custom validator, by providing a function that returns a list of
errors given a subject.

    import Validate exposing (Validator, fromErrors)

    modelValidator : Validator Model String
    modelValidator =
        fromErrors modelToErrors

    modelToErrors : Model -> List String
    modelToErrors model =
        let
            usernameLength =
                String.length model.username
        in
        if usernameLength < minUsernameChars then
            [ "Username not long enough" ]
        else if usernameLength > maxUsernameChars then
            [ "Username too long" ]
        else
            []

-}
fromErrors : (subject -> List error) -> Validator error subject
fromErrors toErrors =
    Validator toErrors


{-| Return an error if a predicate returns `True` for the given
subject.

    import Validate exposing (Validator, ifTrue)

    modelValidator : Validator Model String
    modelValidator =
        ifTrue (\model -> countSelected model < 2)
            "Please select at least two."

-}
ifTrue : (subject -> Bool) -> error -> Validator error subject
ifTrue test error =
    let
        getErrors subject =
            if test subject then
                [ error ]
            else
                []
    in
    Validator getErrors


{-| Return an error if a predicate returns `False` for the given
subject.

    import Validate exposing (Validator, ifFalse)

    modelValidator : Validator Model String
    modelValidator =
        ifFalse (\model -> countSelected model >= 2)
            "Please select at least two."

-}
ifFalse : (subject -> Bool) -> error -> Validator error subject
ifFalse test error =
    let
        getErrors subject =
            if test subject then
                []
            else
                [ error ]
    in
    Validator getErrors



-- COMBINING VALIDATORS --


{-| Run each of the given validators, in order, and return their concatenated
error lists.

    import Validate exposing (Validator, ifBlank, ifNotInt)

    modelValidator : Validator Model String
    modelValidator =
        Validate.all
            [ ifBlank .name "Please enter a name."
            , ifBlank .email "Please enter an email address."
            , ifNotInt .age "Age must be a whole number."
            ]

-}
all : List (Validator error subject) -> Validator error subject
all validators =
    let
        newGetErrors subject =
            let
                accumulateErrors (Validator getErrors) totalErrors =
                    totalErrors ++ getErrors subject
            in
            List.foldl accumulateErrors [] validators
    in
    Validator newGetErrors


{-| Run each of the given validators, in order, stopping after the first error
and returning it. If no errors are encountered, return `Nothing`.

    import Validate exposing (Validator, ifBlank, ifInvalidEmail, ifNotInt)


    type alias Model =
        { email : String, age : String }


    modelValidator : Validator String Model
    modelValidator =
        Validate.all
            [ Validate.firstError
                [ ifBlank .email "Please enter an email address."
                , ifInvalidEmail .email "This is not a valid email address."
                ]
            , ifNotInt .age "Age must be a whole number."
            ]


    validate modelValidator { email = " ", age = "5" }
        --> [ "Please enter an email address." ]

    validate modelValidator { email = "blah", age = "5" }
        --> [ "This is not a valid email address." ]

    validate modelValidator { email = "foo@bar.com", age = "5" }
        --> []

-}
firstError : List (Validator error subject) -> Validator error subject
firstError validators =
    let
        getErrors subject =
            firstErrorHelp validators subject
    in
    Validator getErrors


firstErrorHelp : List (Validator error subject) -> subject -> List error
firstErrorHelp validators subject =
    case validators of
        [] ->
            []

        (Validator getErrors) :: rest ->
            case getErrors subject of
                [] ->
                    firstErrorHelp rest subject

                errors ->
                    errors


{-| Return `True` if none of the given validators returns any errors for the given
subject, and `False` if any validator returns one or more errors.
-}
any : List (Validator error subject) -> subject -> Bool
any validators subject =
    case validators of
        [] ->
            True

        (Validator getErrors) :: others ->
            case getErrors subject of
                [] ->
                    any others subject

                error :: _ ->
                    False



-- CHECKING VALUES DIRECTLY --


{-| Returns `True` if the given string is nothing but whitespace.

[`ifBlank`](#ifBlank) uses this under the hood.

-}
isBlank : String -> Bool
isBlank str =
    Regex.contains lacksNonWhitespaceChars str


{-| Returns `True` if the email is valid.

[`ifInvalidEmail`](#ifInvalidEmail) uses this under the hood.

-}
isValidEmail : String -> Bool
isValidEmail email =
    Regex.contains validEmail email


{-| Returns `True` if `String.toInt` on the given string returns an `Ok`.

[`ifNotInt`](#ifNotInt) uses this under the hood.

-}
isInt : String -> Bool
isInt str =
    case String.toInt str of
        Ok _ ->
            True

        Err _ ->
            False



-- INTERNAL HELPERS --


lacksNonWhitespaceChars : Regex
lacksNonWhitespaceChars =
    Regex.regex "^\\s*$"


validEmail : Regex
validEmail =
    Regex.regex "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Regex.caseInsensitive
