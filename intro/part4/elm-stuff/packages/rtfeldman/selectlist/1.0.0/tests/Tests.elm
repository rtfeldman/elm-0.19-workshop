module Tests exposing (..)

import Test exposing (..)
import Expect exposing (Expectation)
import Fuzz exposing (list, int, tuple, string)
import SelectList exposing (Position(..))
import List.Extra


access : Test
access =
    describe "before, selected, after"
        [ fuzzSegments "before" <|
            \beforeSel sel afterSel ->
                SelectList.fromLists beforeSel sel afterSel
                    |> SelectList.before
                    |> Expect.equal beforeSel
        , fuzzSegments "selected" <|
            \beforeSel sel afterSel ->
                SelectList.fromLists beforeSel sel afterSel
                    |> SelectList.selected
                    |> Expect.equal sel
        , fuzzSegments "after" <|
            \beforeSel sel afterSel ->
                SelectList.fromLists beforeSel sel afterSel
                    |> SelectList.after
                    |> Expect.equal afterSel
        , fuzzSegments "toList" <|
            \beforeSel sel afterSel ->
                SelectList.fromLists beforeSel sel afterSel
                    |> SelectList.toList
                    |> Expect.equal (beforeSel ++ sel :: afterSel)
        ]


transforming : Test
transforming =
    describe "transforming" <|
        [ fuzzSegments "append" <|
            \beforeSel sel afterSel ->
                SelectList.fromLists beforeSel sel afterSel
                    |> SelectList.append beforeSel
                    |> Expect.equal (SelectList.fromLists beforeSel sel (afterSel ++ beforeSel))
        , fuzzSegments "prepend" <|
            \beforeSel sel afterSel ->
                SelectList.fromLists beforeSel sel afterSel
                    |> SelectList.prepend afterSel
                    |> Expect.equal (SelectList.fromLists (afterSel ++ beforeSel) sel afterSel)
        , describe "mapBy"
            [ fuzzSegments "mapBy transforms every element" <|
                \beforeSel sel afterSel ->
                    SelectList.fromLists beforeSel sel afterSel
                        |> SelectList.mapBy (\_ num -> num * sel)
                        |> Expect.equal
                            (SelectList.fromLists
                                (List.map (\num -> num * sel) beforeSel)
                                (sel * sel)
                                (List.map (\num -> num * sel) afterSel)
                            )
            , fuzzSegments "mapBy passes the selected elem" <|
                \beforeSel sel afterSel ->
                    SelectList.fromLists beforeSel sel afterSel
                        |> SelectList.mapBy (\isSelected _ -> isSelected)
                        |> Expect.equal
                            (SelectList.fromLists
                                (List.map (\_ -> BeforeSelected) beforeSel)
                                Selected
                                (List.map (\_ -> AfterSelected) afterSel)
                            )
            ]
        , describe "select"
            [ fuzzSegments "is a no-op when trying to select what's already selected" <|
                \beforeSel sel afterSel ->
                    let
                        original =
                            -- make only the selected one negative
                            SelectList.fromLists beforeSel sel afterSel
                                |> SelectList.mapBy
                                    (\position elem ->
                                        if position == Selected then
                                            negate elem
                                        else
                                            elem
                                    )
                    in
                        original
                            |> SelectList.select (\num -> num < 0)
                            |> Expect.equal original
            , fuzzSegments "is a no-op when the predicate fails every time" <|
                \beforeSel sel afterSel ->
                    let
                        original =
                            SelectList.fromLists beforeSel sel afterSel
                    in
                        original
                            |> SelectList.select (\num -> num < 0)
                            |> Expect.equal original
            , fuzzSegments "selects the first one it finds" <|
                \beforeSel sel afterSel ->
                    let
                        predicate num =
                            num > 5

                        firstInList =
                            (beforeSel ++ sel :: afterSel)
                                |> List.Extra.find predicate
                                |> Maybe.withDefault sel
                    in
                        SelectList.fromLists beforeSel sel afterSel
                            |> SelectList.select predicate
                            |> SelectList.selected
                            |> Expect.equal firstInList
            , describe "selects the first one it finds in a hardcoded list"
                [ test "where it's the beginning of the `before` list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 1 ]
                            |> SelectList.select (\num -> num > 0)
                            |> Expect.equal (SelectList.fromLists [] 1 [ 2, 3, 4, 5, 2, 1 ])
                , test "where it's the middle of the `before` list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 1 ]
                            |> SelectList.select (\num -> num > 1)
                            |> Expect.equal (SelectList.fromLists [ 1 ] 2 [ 3, 4, 5, 2, 1 ])
                , test "where it's the end of the `before` list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 1 ]
                            |> SelectList.select (\num -> num > 2)
                            |> Expect.equal (SelectList.fromLists [ 1, 2 ] 3 [ 4, 5, 2, 1 ])
                , test "where it's the selected element in the list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 1 ]
                            |> SelectList.select (\num -> num > 3)
                            |> Expect.equal (SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 1 ])
                , test "where it's the beginning of the `after` list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 5, 1 ]
                            |> SelectList.select (\num -> num > 4)
                            |> Expect.equal (SelectList.fromLists [ 1, 2, 3, 4 ] 5 [ 2, 5, 1 ])
                , test "where it's the middle of the `after` list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 5, 6, 1, 6, 7 ]
                            |> SelectList.select (\num -> num > 5)
                            |> Expect.equal (SelectList.fromLists [ 1, 2, 3, 4, 5, 2, 5 ] 6 [ 1, 6, 7 ])
                , test "where it's the end of the `after` list" <|
                    \() ->
                        SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 2, 5, 6, 1, 6, 7 ]
                            |> SelectList.select (\num -> num > 6)
                            |> Expect.equal (SelectList.fromLists [ 1, 2, 3, 4, 5, 2, 5, 6, 1, 6 ] 7 [])
                ]
            ]
        ]


{-| Choose positive ints so that we can throw a negative one in there and
detect it later.
-}
fuzzSegments : String -> (List Int -> Int -> List Int -> Expectation) -> Test
fuzzSegments =
    fuzz3 (list positiveInt) positiveInt (list positiveInt)


positiveInt : Fuzz.Fuzzer Int
positiveInt =
    Fuzz.map abs int
