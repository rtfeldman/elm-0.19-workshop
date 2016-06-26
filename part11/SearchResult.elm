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
    case msg of
        Expand ->
            { model | expanded = True } ! []

        Collapse ->
            { model | expanded = False } ! []


view : Model -> Html Msg
view model =
    li []
        <| if model.expanded then
            [ span [ class "star-count" ] [ text (toString model.stars) ]
            , a
                [ href
                    ("https://github.com/"
                        ++ (Debug.log "TODO we should not see this when typing in the search box!"
                                model.name
                           )
                    )
                , target "_blank"
                ]
                [ text model.name ]
            , button [ class "hide-result", onClick Collapse ]
                [ text "X" ]
            ]
           else
            [ button [ class "expand-result", onClick Expand ]
                [ text "Show" ]
            ]
