module SignupForm exposing (..)

import Validate exposing (Validator, ifBlank, ifEmptyList, ifInvalidEmail, ifNotInt, validate)


type alias Model =
    { name : String, email : String, age : String, selections : List Float }


type Field
    = Name
    | Email
    | Age
    | Selections


modelValidator : Validator ( Field, String ) Model
modelValidator =
    Validate.all
        [ ifBlank .name ( Name, "Please enter a name." )
        , Validate.firstError
            [ ifBlank .email ( Email, "Please enter an email address." )
            , ifInvalidEmail .email ( Email, "This is not a valid email address." )
            ]
        , ifNotInt .age ( Age, "Age must be a whole number." )
        , ifEmptyList .selections ( Selections, "Please select at least one." )
        ]


result : Bool
result =
    validate modelValidator
        { name = "Sam", email = "", age = "abc", selections = [ 1.2 ] }
        == [ ( Email, "Please enter an email address." )
           , ( Age, "Age must be a whole number." )
           ]
