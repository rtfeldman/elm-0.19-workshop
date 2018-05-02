port module Main exposing (..)

import Test
import Test.Runner.Node as Runner exposing (TestProgram)
import Tests
import Json.Encode exposing (Value)


port emit : ( String, Value ) -> Cmd msg


main : TestProgram
main =
    Runner.run emit Tests.all
