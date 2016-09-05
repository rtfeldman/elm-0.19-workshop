module SearchOptions exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, checked, type', defaultValue)
import Html.Events exposing (..)
import String


view : Model -> Html Msg
view model =
    div []
        [ input [ type' "text", defaultValue model.sort, onInput SetSort ] []
        , input [ type' "text", defaultValue model.order, onInput SetOrder ] []
        , input [ type' "text", defaultValue (String.join " " model.searchIn) ] []
        , input [ type' "checkbox", checked model.includeForks ] []
        , input [ type' "text", defaultValue model.userFilter, onInput SetUserFilter ] []
        ]


type alias Model =
    { sort : String
    , order : String
    , searchIn : List String
    , includeForks : Bool
    , userFilter : String
    }


type Msg
    = SetSort String
    | SetOrder String
    | SetSearchIn (List String)
    | SetIncludeForks Bool
    | SetUserFilter String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetSort sort ->
            { model | sort = sort }

        SetOrder order ->
            { model | order = order }

        SetSearchIn searchIn ->
            { model | searchIn = searchIn }

        SetIncludeForks includeForks ->
            { model | includeForks = includeForks }

        SetUserFilter userFilter ->
            { model | userFilter = userFilter }


initialModel : Model
initialModel =
    { sort = ""
    , order = ""
    , searchIn = []
    , includeForks = True
    , userFilter = ""
    }
