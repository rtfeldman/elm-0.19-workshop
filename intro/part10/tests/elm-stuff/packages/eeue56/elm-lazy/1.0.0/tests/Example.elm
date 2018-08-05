module Example exposing (..)

import Lazy
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string)
import Test exposing (..)


suite : Test
suite =
    describe "Laziness"
        [ fuzz int
            "lazy and force"
            (\x ->
                Lazy.lazy (\() -> x)
                    |> Lazy.force
                    |> Expect.equal x
            )
        , fuzz int
            "evaluate"
            (\x ->
                Lazy.lazy (\() -> x)
                    |> Lazy.evaluate
                    |> Lazy.force
                    |> Expect.equal x
            )
        , fuzz int
            "map"
            (\x ->
                Lazy.lazy (\() -> x)
                    |> Lazy.map (\x -> x + 1)
                    |> Lazy.force
                    |> Expect.equal (x + 1)
            )
        , fuzz2 int
            int
            "map2"
            (\x y ->
                Lazy.map2 (\x y -> x + y) (Lazy.lazy (\() -> x)) (Lazy.lazy (\() -> y))
                    |> Lazy.force
                    |> Expect.equal (x + y)
            )
        ]
