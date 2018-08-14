module PaginatedList exposing (PaginatedList, fromList, fromRequestBuilder, map, page, total, values)

import Html exposing (Html, a, li, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)
import Http
import HttpBuilder exposing (RequestBuilder)
import Task exposing (Task)



-- TYPES


type PaginatedList a
    = PaginatedList
        { values : List a
        , total : Int
        , page : Int
        }



-- INFO


values : PaginatedList a -> List a
values (PaginatedList info) =
    info.values


total : PaginatedList a -> Int
total (PaginatedList info) =
    info.total


page : PaginatedList a -> Int
page (PaginatedList info) =
    info.page



-- CREATE


fromList : Int -> List a -> PaginatedList a
fromList totalCount list =
    PaginatedList { values = list, total = totalCount, page = 1 }



-- TRANSFORM


map : (a -> a) -> PaginatedList a -> PaginatedList a
map transform (PaginatedList info) =
    PaginatedList { info | values = List.map transform info.values }



-- HTTP


{-| I considered accepting a record here so I don't mess up the argument order.
-}
fromRequestBuilder :
    Int
    -> Int
    -> RequestBuilder (PaginatedList a)
    -> Task Http.Error (PaginatedList a)
fromRequestBuilder resultsPerPage pageNumber builder =
    let
        offset =
            (pageNumber - 1) * resultsPerPage

        params =
            [ ( "limit", String.fromInt resultsPerPage )
            , ( "offset", String.fromInt offset )
            ]
    in
    builder
        |> HttpBuilder.withQueryParams params
        |> HttpBuilder.toRequest
        |> Http.toTask
        |> Task.map (\(PaginatedList info) -> PaginatedList { info | page = pageNumber })



-- VIEW
