# elm-lazy


This library provides a way of putting of computations until they are needed, allowing for expensive calculations later.

    lazySum : Lazy Int
    lazySum =
        lazy (\() -> sum <| List.range 1 1000000)

It also gives you a way of storing a computed value so that you do not need to re-compute it.

    lazySum : Int -> Lazy Int
    lazySum n =
        lazy (\() -> sum <| List.range 0 n)


    lazySums : List Int -> List (Lazy Int)
    lazySums sums =
        List.map lazySum sums

    -- evaluates the head, before putting it back on the list
    evaluteCurrentSum : List (Lazy Int) -> List (Lazy Int)
    evaluteCurrentSum xs =
       case xs of 
         head::rest -> Lazy.evaluate head :: rest
         _ -> []


## Notes


This is a library based originally on the old `Lazy` implementation. However, it is written entirely in pure Elm. The main difference is explicit memoization, as we no longer use side-effects to achieve laziness.