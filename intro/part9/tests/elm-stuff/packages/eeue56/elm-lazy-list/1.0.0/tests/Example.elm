module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string)
import Test exposing (..)
import Lazy.List exposing (..)


suite : Test
suite =
    describe "List.lazy"
        [ test "Empty things are empty"
            (\_ ->
                empty
                    |> isEmpty
                    |> Expect.true "Empty is empty"
            )
        , test "A list of two things has two things"
            (\_ ->
                singleton 5
                    |> cons 6
                    |> toList
                    |> Expect.equal [ 6, 5 ]
            )
        , test "The sum is correctly computed"
            (\_ ->
                singleton 10
                    |> cons 6
                    |> sum
                    |> Expect.equal 16
            )
        ]
