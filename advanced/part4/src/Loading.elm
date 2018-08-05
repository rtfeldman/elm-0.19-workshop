module Loading exposing (error, icon)

{-| A loading spinner icon.
-}

import Html exposing (Attribute, Html, div, li)
import Html.Attributes exposing (class, style)


icon : Html msg
icon =
    li [ class "sk-three-bounce", style "float" "left", style "margin" "8px" ]
        [ div [ class "sk-child sk-bounce1" ] []
        , div [ class "sk-child sk-bounce2" ] []
        , div [ class "sk-child sk-bounce3" ] []
        ]


error : String -> Html msg
error str =
    Html.text ("Error loading " ++ str ++ ".")
