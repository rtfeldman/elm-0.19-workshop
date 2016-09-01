module Pages.Repository exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import ElmHub exposing (SearchResult)


type alias Model =
    SearchResult


init : Int -> ( Model, Cmd Msg )
init id =
    ( { id = id
      , name = ""
      , stars = id
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text ("repo" ++ toString model.stars) ]
        ]


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
