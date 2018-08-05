# elm-lazy-list

This package is used to represent an infinite list of values, to be computed as they are needed. It is mainly designed for use with Elm test.


    singleton 5
        |> cons 6
        -- only evaluated here!
        |> toList --> 6, 5 