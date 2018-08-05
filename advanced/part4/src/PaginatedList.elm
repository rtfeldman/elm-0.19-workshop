module PaginatedList exposing (PaginatedList, fromList, map, mapPage, page, total, values)

import Html exposing (Html, a, li, text, ul)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onClick)



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


mapPage : (Int -> Int) -> PaginatedList a -> PaginatedList a
mapPage transform (PaginatedList info) =
    PaginatedList { info | page = transform info.page }



-- VIEW
