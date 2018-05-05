module Data.Article.Author exposing (Author, decoder)

import Data.User as User exposing (Username)
import Data.UserPhoto as UserPhoto exposing (UserPhoto)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, decode, optional, required)


decoder : Decoder Author
decoder =
    decode Author
        |> required "username" User.usernameDecoder
        |> required "bio" (Decode.nullable Decode.string)
        |> required "image" UserPhoto.decoder
        |> optional "following" Decode.bool False


type alias Author =
    { username : Username
    , bio : Maybe String
    , image : UserPhoto
    , following : Bool
    }
