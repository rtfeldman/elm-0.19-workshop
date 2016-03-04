module Tests where

import ElmTest exposing (..)

import String


all : Test
all =
    suite "A Test Suite"
        [
            test "Addition" (assertEqual (3 + 7) 10),
            test "String.left" (assertEqual "a" (String.left 1 "abcdefg")),
            test "This test should fail" (assert False)
        ]
