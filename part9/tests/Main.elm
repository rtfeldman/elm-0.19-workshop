port module Main exposing (..)

import Tests
import Test.Runner.Node as Runner
import Json.Decode exposing (Value)


-- To run this:
--
-- elm-test


main : Runner.TestProgram
main =
    Runner.run emit Tests.all


port emit : ( String, Value ) -> Cmd msg
