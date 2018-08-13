module Timestamp exposing (format, iso8601Decoder, view)

import Html exposing (Html, span, text)
import Html.Attributes exposing (class)
import Iso8601
import Json.Decode as Decode exposing (Decoder, fail, succeed)
import Time exposing (Month(..))



-- VIEW


view : Time.Zone -> Time.Posix -> Html msg
view timeZone timestamp =
    span [ class "date" ] [ text (format timeZone timestamp) ]



-- DECODE


{-| Decode an ISO-8601 date string.
-}
iso8601Decoder : Decoder Time.Posix
iso8601Decoder =
    {- 👉 TODO: Use the following function to decode this Time.Posix value:


       Iso8601.toTime : String -> Result (List DeadEnd) Time.Posix


       ❕ NOTE: You can disregard the (List DeadEnd) here. No need to use it to complete this exercise!

       💡 HINT: Decode.andThen will be useful here.
    -}
    "..."



-- FORMAT


{-| Format a timestamp as a String, like so:

    "February 14, 2018"

For more complex date formatting scenarios, here's a nice package:
<https://package.elm-lang.org/packages/ryannhg/date-format/latest/>

-}
format : Time.Zone -> Time.Posix -> String
format zone time =
    let
        month =
            case Time.toMonth zone time of
                Jan ->
                    "January"

                Feb ->
                    "February"

                Mar ->
                    "March"

                Apr ->
                    "April"

                May ->
                    "May"

                Jun ->
                    "June"

                Jul ->
                    "July"

                Aug ->
                    "August"

                Sep ->
                    "September"

                Oct ->
                    "October"

                Nov ->
                    "November"

                Dec ->
                    "December"

        day =
            String.fromInt (Time.toDay zone time)

        year =
            String.fromInt (Time.toYear zone time)
    in
    month ++ " " ++ day ++ ", " ++ year
