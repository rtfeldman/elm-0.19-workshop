module Page.Repository exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, target, href, property, defaultValue, src)
import Auth
import Http
import Task
import Json.Decode exposing (Decoder, int, string, list)
import Json.Decode.Pipeline exposing (decode, required)


type alias Model =
    { repoOwner : String
    , repoName : String
    , repository : Maybe Repository
    }


type alias Repository =
    { id : Int
    , issues : Int
    , forks : Int
    , watchers : Int
    , owner : User
    , description : String
    }


type alias User =
    { id : Int
    , username : String
    , avatarUrl : String
    , profileUrl : String
    }


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "id" int
        |> required "login" string
        |> required "avatar_url" string
        |> required "url" string


repoDecoder : Decoder Repository
repoDecoder =
    decode Repository
        |> required "id" int
        |> required "open_issues_count" int
        |> required "forks" int
        |> required "watchers" int
        |> required "owner" userDecoder
        |> required "description" string


init : String -> String -> ( Model, Cmd Msg )
init repoOwner repoName =
    ( { repoOwner = repoOwner
      , repoName = repoName
      , repository = Nothing
      }
    , getRepoInfo repoOwner repoName
    )


view : Model -> Html Msg
view model =
    let
        ownerUrl =
            "https://github.com/" ++ model.repoOwner

        repoUrl =
            ownerUrl ++ "/" ++ model.repoName

        details =
            model.repository
                |> Maybe.map viewDetails
                |> Maybe.withDefault (text "")
    in
        div []
            [ h1 []
                [ a [ href repoUrl ] [ text model.repoName ] ]
            , details
            ]


viewDetails : Repository -> Html Msg
viewDetails repo =
    div []
        [ p [] [ text repo.description ]
        , h2 []
            [ a [ href repo.owner.profileUrl ]
                [ img [ class "profile-photo", src repo.owner.avatarUrl ] []
                , text repo.owner.username
                ]
            ]
        , table []
            [ tbody []
                [ tr [] [ th [] [ text "issues" ], td [] [ text (toString repo.issues) ] ]
                , tr [] [ th [] [ text "forks" ], td [] [ text (toString repo.forks) ] ]
                , tr [] [ th [] [ text "watchers" ], td [] [ text (toString repo.watchers) ] ]
                ]
            ]
        ]


type Msg
    = HandleRepoError Http.Error
    | HandleRepoResponse Repository


getRepoInfo : String -> String -> Cmd Msg
getRepoInfo repoOwner repoName =
    let
        url =
            "https://api.github.com/repos/"
                ++ repoOwner
                ++ "/"
                ++ repoName
                ++ "?access_token="
                ++ Auth.token
                |> Debug.log "getRepoInfo"
    in
        Http.get repoDecoder url
            |> Task.perform HandleRepoError HandleRepoResponse


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleRepoError err ->
            ( model, Cmd.none )

        HandleRepoResponse repository ->
            ( { model | repository = Just repository }, Cmd.none )
