module Main exposing (..)

import Benchmark exposing (..)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import CoreLazy
import Lazy


basicInt : Lazy.Lazy Int
basicInt =
    Lazy.lazy (\() -> 1)


basicCoreInt : CoreLazy.Lazy Int
basicCoreInt =
    CoreLazy.lazy (\() -> 1)


bigThunk : () -> List Int
bigThunk _ =
    List.range 0 10000


complexThing : () -> Lazy.Lazy (List Int)
complexThing _ =
    Lazy.lazy (\() -> List.range 0 10000)


complexCoreThing : () -> CoreLazy.Lazy (List Int)
complexCoreThing _ =
    CoreLazy.lazy (\() -> List.range 0 10000)


suite : Benchmark
suite =
    describe "Lazy"
        [ describe "force"
            [ benchmark1 "force" Lazy.force basicInt
            , Benchmark.compare "forcing a small int"
                (benchmark1 "eeue56" Lazy.force basicInt)
                (benchmark1 "core" CoreLazy.force basicCoreInt)
            , Benchmark.compare "forcing a large list"
                (benchmark "eeue56" (complexThing >> Lazy.force))
                (benchmark "core" (complexCoreThing >> CoreLazy.force))
            , Benchmark.compare "memoization"
                (benchmark1 "eeue56"
                    (\thing ->
                        let
                            xs =
                                Lazy.lazy thing

                            firstPass =
                                Lazy.evaluate xs

                            secondPass =
                                Lazy.evaluate firstPass
                        in
                            secondPass |> Lazy.force
                    )
                    bigThunk
                )
                (benchmark1 "core"
                    (\thing ->
                        let
                            xs =
                                CoreLazy.lazy thing

                            firstPass =
                                CoreLazy.force xs

                            secondPass =
                                CoreLazy.force xs
                        in
                            xs |> CoreLazy.force
                    )
                    bigThunk
                )
            , Benchmark.compare "memoization foldl"
                (benchmark1 "eeue56"
                    (\thing ->
                        List.foldl (\_ lazyThing -> Lazy.evaluate lazyThing) (Lazy.lazy thing) (List.range 0 5)
                            |> Lazy.force
                    )
                    bigThunk
                )
                (benchmark1 "core"
                    (\thing ->
                        List.foldl
                            (\_ lazyThing ->
                                let
                                    _ =
                                        CoreLazy.force lazyThing
                                in
                                    lazyThing
                            )
                            (CoreLazy.lazy thing)
                            (List.range 0 5)
                            |> CoreLazy.force
                    )
                    bigThunk
                )
            ]
        ]


main : BenchmarkProgram
main =
    program suite
