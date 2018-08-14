module Main exposing (main)

import Article
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



-- MODEL


type alias Model =
    { tags : List String
    , selectedTag : String
    , allArticles : List Article
    }


type alias Article =
    { title : String
    , description : String
    , body : String
    , tags : List String
    , slug : String
    }


initialModel : Model
initialModel =
    { tags = Article.tags
    , selectedTag = "elm"
    , allArticles = Article.feed
    }



-- UPDATE


type alias Msg =
    { description : String
    , data : String
    }


update : Msg -> Model -> Model
update msg model =
    if msg.description == "ClickedTag" then
        { model | selectedTag = msg.data }

    else
        model



-- VIEW


view : Model -> Html Msg
view model =
    let
        articles =
            List.filter (\article -> List.member model.selectedTag article.tags)
                model.allArticles

        feed =
            List.map viewArticle articles
    in
    div [ class "home-page" ]
        [ viewBanner
        , div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-9" ] feed
                , div [ class "col-md-3" ]
                    [ div [ class "sidebar" ]
                        [ p [] [ text "Popular Tags" ]
                        , viewTags model
                        ]
                    ]
                ]
            ]
        ]


viewArticle : Article -> Html Msg
viewArticle article =
    div [ class "article-preview" ]
        [ h1 [] [ text article.title ]
        , p [] [ text article.description ]
        , span [] [ text "Read more..." ]
        ]


viewBanner : Html Msg
viewBanner =
    div [ class "banner" ]
        [ div [ class "container" ]
            [ h1 [ class "logo-font" ] [ text "conduit" ]
            , p [] [ text "A place to share your knowledge." ]
            ]
        ]


viewTag : String -> String -> Html Msg
viewTag selectedTagName tagName =
    let
        otherClass =
            if tagName == selectedTagName then
                "tag-selected"

            else
                "tag-default"
    in
    button
        [ class ("tag-pill " ++ otherClass)
        , onClick { description = "ClickedTag", data = tagName }
        ]
        [ text tagName ]


viewTags : Model -> Html Msg
viewTags model =
    div [ class "tag-list" ] (List.map (viewTag model.selectedTag) model.tags)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
