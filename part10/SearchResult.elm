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
    model ! []


view : Model -> Html Msg
view model =
    if model.expanded then
        li []
            [ span [ class "star-count" ] [ text (toString model.stars) ]
            , a [ href ("https://github.com/" ++ model.name), target "_blank" ]
                [ text model.name ]
              -- TODO send a Collapse message on click
            , button [ class "hide-result" ]
                [ text "X" ]
            ]
    else
        li []
            -- TODO send an Expand message on click
            [ button [ class "expand-result" ]
                [ text "Show" ]
            ]
