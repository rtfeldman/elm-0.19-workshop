port module Main exposing (..)

import Tests
import Test.Runner.Node as Runner
import Json.Decode exposing (Value)


-- To run this:
--
-- cd into part8/test
-- elm-test NodeRunner.elm


main : Program Never
main =
    Runner.run emit Tests.all


port emit : ( String, Value ) -> Cmd msg
