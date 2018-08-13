module PaginatedList exposing (PaginatedList, fromList, map, mapPage, page, total, values, view)

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


view : (Int -> msg) -> PaginatedList a -> Int -> Html msg
view toMsg list resultsPerPage =
    let
        totalPages =
            ceiling (toFloat (total list) / toFloat resultsPerPage)

        activePage =
            page list

        viewPageLink currentPage =
            pageLink toMsg currentPage (currentPage == activePage)
    in
    if totalPages > 1 then
        List.range 1 totalPages
            |> List.map viewPageLink
            |> ul [ class "pagination" ]

    else
        Html.text ""


pageLink : (Int -> msg) -> Int -> Bool -> Html msg
pageLink toMsg targetPage isActive =
    li [ classList [ ( "page-item", True ), ( "active", isActive ) ] ]
        [ a
            [ class "page-link"
            , onClick (toMsg targetPage)

            -- The RealWorld CSS requires an href to work properly.
            , href ""
            ]
            [ text (String.fromInt targetPage) ]
        ]
