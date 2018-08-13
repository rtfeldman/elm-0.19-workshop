module Article.Comment
    exposing
        ( Comment
        , author
        , body
        , createdAt
        , delete
        , id
        , list
        , post
        )

import Api
import Article exposing (Article)
import Article.Slug as Slug exposing (Slug)
import Author exposing (Author)
import CommentId exposing (CommentId)
import Http
import HttpBuilder exposing (RequestBuilder, withExpect, withQueryParams)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode exposing (Value)
import Profile exposing (Profile)
import Time
import Timestamp
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)



-- TYPES


type Comment
    = Comment Internals


type alias Internals =
    { id : CommentId
    , body : String
    , createdAt : Time.Posix
    , author : Author
    }



-- INFO


id : Comment -> CommentId
id (Comment comment) =
    comment.id


body : Comment -> String
body (Comment comment) =
    comment.body


createdAt : Comment -> Time.Posix
createdAt (Comment comment) =
    comment.createdAt


author : Comment -> Author
author (Comment comment) =
    comment.author



-- LIST


list : Maybe Cred -> Slug -> Http.Request (List Comment)
list maybeCred articleSlug =
    allCommentsUrl articleSlug []
        |> HttpBuilder.get
        |> HttpBuilder.withExpect (Http.expectJson (Decode.field "comments" (Decode.list (decoder maybeCred))))
        |> Cred.addHeaderIfAvailable maybeCred
        |> HttpBuilder.toRequest



-- POST


post : Slug -> String -> Cred -> Http.Request Comment
post articleSlug commentBody cred =
    allCommentsUrl articleSlug []
        |> HttpBuilder.post
        |> HttpBuilder.withBody (Http.jsonBody (encodeCommentBody commentBody))
        |> HttpBuilder.withExpect (Http.expectJson (Decode.field "comment" (decoder (Just cred))))
        |> Cred.addHeader cred
        |> HttpBuilder.toRequest


encodeCommentBody : String -> Value
encodeCommentBody str =
    Encode.object [ ( "comment", Encode.object [ ( "body", Encode.string str ) ] ) ]



-- DELETE


delete : Slug -> CommentId -> Cred -> Http.Request ()
delete articleSlug commentId cred =
    commentUrl articleSlug commentId
        |> HttpBuilder.delete
        |> Cred.addHeader cred
        |> HttpBuilder.toRequest



-- SERIALIZATION


decoder : Maybe Cred -> Decoder Comment
decoder maybeCred =
    Decode.succeed Internals
        |> required "id" CommentId.decoder
        |> required "body" Decode.string
        |> required "createdAt" Timestamp.iso8601Decoder
        |> required "author" (Author.decoder maybeCred)
        |> Decode.map Comment



-- URLS


commentUrl : Slug -> CommentId -> String
commentUrl articleSlug commentId =
    allCommentsUrl articleSlug [ CommentId.toString commentId ]


allCommentsUrl : Slug -> List String -> String
allCommentsUrl articleSlug paths =
    Api.url ([ "articles", Slug.toString articleSlug, "comments" ] ++ paths)
