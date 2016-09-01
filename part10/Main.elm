module Main exposing (..)

import Pages.Home
import Pages.Repository
import Navigation
import Page exposing (Page(..))
import Tuple2
import Html exposing (Html, div, h1, header, text, span)
import Html.Attributes exposing (class)
import Html.App as Html


type Model
    = Home Pages.Home.Model
    | Repository Pages.Repository.Model


type Msg
    = HomeMsg Pages.Home.Msg
    | RepositoryMsg Pages.Repository.Msg


main : Program Never
main =
    Navigation.program (Navigation.makeParser Page.parser)
        { init = init
        , subscriptions = subscriptions
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Home pageModel ->
            Pages.Home.subscriptions pageModel
                |> Sub.map HomeMsg

        Repository pageModel ->
            Sub.none


init : Result String Page -> ( Model, Cmd Msg )
init result =
    Home (fst Pages.Home.init)
        |> urlUpdate result


view : Model -> Html Msg
view model =
    withHeader <|
        case model of
            Home pageModel ->
                Pages.Home.view pageModel
                    |> Html.map HomeMsg

            Repository pageModel ->
                Pages.Repository.view pageModel
                    |> Html.map RepositoryMsg


withHeader : Html msg -> Html msg
withHeader innerContent =
    div [ class "content" ]
        [ header []
            [ h1 [] [ text "ElmHub" ]
            , span [ class "tagline" ] [ text "Like GitHub, but for Elm things." ]
            ]
        , innerContent
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( HomeMsg pageMsg, Home pageModel ) ->
            Pages.Home.update pageMsg pageModel
                |> Tuple2.mapEach Home (Cmd.map HomeMsg)

        ( RepositoryMsg pageMsg, Repository pageModel ) ->
            Pages.Repository.update pageMsg pageModel
                |> Tuple2.mapEach Repository (Cmd.map RepositoryMsg)

        ( _, _ ) ->
            ( model, Cmd.none )


urlUpdate : Result String Page -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    case result of
        Ok (Page.Home) ->
            Pages.Home.init
                |> Tuple2.mapEach Home (Cmd.map HomeMsg)

        Ok (Page.Repository id) ->
            Pages.Repository.init id
                |> Tuple2.mapEach Repository (Cmd.map RepositoryMsg)

        Ok NotFound ->
            ( model, Cmd.none )

        Err _ ->
            ( model, Navigation.modifyUrl "/" )
