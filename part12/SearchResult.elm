module SearchResult exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)


type alias Model =
    { id : Int
    , name : String
    , stars : Int
    , expanded : Bool
    }


type alias ResultId =
    Int


type Msg
    = Expand
    | Collapse


decoder : Decoder Model
decoder =
    decode Model
        |> required "id" Json.Decode.int
        |> required "full_name" Json.Decode.string
        |> required "stargazers_count" Json.Decode.int
        |> hardcoded True


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- TODO implement Expand and Collapse logic
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    li [] <|
        if model.expanded then
            [ span [ class "star-count" ] [ text (toString model.stars) ]
            , a [ href ("https://github.com/" ++ model.name), target "_blank" ]
                [ text model.name ]
            , button
                -- TODO when the user clicks, send a Collapse action
                [ class "hide-result" ]
                [ text "X" ]
            ]
        else
            [ button
                -- TODO when the user clicks, send an Expand action
                [ class "expand-result" ]
                [ text "Show" ]
            ]
