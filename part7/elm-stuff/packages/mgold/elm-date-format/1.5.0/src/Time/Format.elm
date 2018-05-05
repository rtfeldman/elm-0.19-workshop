module Time.Format exposing (format)

{-| Format strings for times.

@docs format
-}

import Time
import Date.Format
import Date


{-| Use a format string to format a time. See the
[README](https://github.com/mgold/elm-date-format/blob/master/README.md) for a
list of accepted formatters.
-}
format : String -> Time.Time -> String
format s t =
    Date.Format.format s (Date.fromTime t)
