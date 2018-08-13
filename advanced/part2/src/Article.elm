module Article
    exposing
        ( Article
        , Full
        , Preview
        , author
        , body
        , favorite
        , favoriteButton
        , fetch
        , fromPreview
        , fullDecoder
        , mapAuthor
        , metadata
        , previewDecoder
        , slug
        , unfavorite
        , unfavoriteButton
        , url
        )

{-| The interface to the Article data structure.

This includes:

  - The Article type itself
  - Ways to make HTTP requests to retrieve and modify articles
  - Ways to access information about an article
  - Converting between various types

-}

import Api
import Article.Body as Body exposing (Body)
import Article.Slug as Slug exposing (Slug)
import Article.Tag as Tag exposing (Tag)
import Author exposing (Author)
import Html exposing (Attribute, Html, i)
import Html.Attributes exposing (class)
import Html.Events exposing (stopPropagationOn)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)
import Json.Encode as Encode
import Markdown
import Profile exposing (Profile)
import Time
import Timestamp
import Username as Username exposing (Username)
import Viewer exposing (Viewer)
import Viewer.Cred as Cred exposing (Cred)



-- TYPES


{-| An article, optionally with an article body.

To see the difference between { extraInfo : a } and { extraInfo : Maybe Body },
consider the difference between the "view individual article" page (which
renders one article, including its body) and the "article feed" -
which displays multiple articles, but without bodies.

This definition for `Article` means we can write:

viewArticle : Article Full -> Html msg
viewFeed : List (Article Preview) -> Html msg

This indicates that `viewArticle` requires an article _with a `body` present_,
wereas `viewFeed` accepts articles with no bodies. (We could also have written
it as `List (Article a)` to specify that feeds can accept either articles that
have `body` present or not. Either work, given that feeds do not attempt to
read the `body` field from articles.)

This is an important distinction, because in Request.Article, the `feed`
function produces `List (Article Preview)` because the API does not return bodies.
Those articles are useful to the feed, but not to the individual article view.

-}
type Article a
    = Article Internals a


{-| Metadata about the article - its title, description, and so on.

Importantly, this module's public API exposes a way to read this metadata, but
not to alter it. This is read-only information!

If we find ourselves using any particular piece of metadata often,
for example `title`, we could expose a convenience function like this:

Article.title : Article a -> String

If you like, it's totally reasonable to expose a function like that for every one
of these fields!

(Okay, to be completely honest, exposing one function per field is how I prefer
to do it, and that's how I originally wrote this module. However, I'm aware that
this code base has become a common reference point for beginners, and I think it
is _extremely important_ that slapping some "getters and setters" on a record
does not become a habit for anyone who is getting started with Elm. The whole
point of making the Article type opaque is to create guarantees through
_selectively choosing boundaries_ around it. If you aren't selective about
where those boundaries are, and instead expose a "getter and setter" for every
field in the record, the result is an API with no more guarantees than if you'd
exposed the entire record directly! It is so important to me that beginners not
fall into the terrible "getters and setters" trap that I've exposed this
Metadata record instead of exposing a single function for each of its fields,
as I did originally. This record is not a bad way to do it, by any means,
but if this seems at odds with <https://youtu.be/x1FU3e0sT1I> - now you know why!
See commit c2640ae3abd60262cdaafe6adee3f41d84cd85c3 for how it looked before.
)

-}
type alias Metadata =
    { description : String
    , title : String
    , tags : List String
    , createdAt : Time.Posix
    , favorited : Bool
    , favoritesCount : Int
    }


type alias Internals =
    { slug : Slug
    , author : Author
    , metadata : Metadata
    }


type Preview
    = Preview


type Full
    = Full Body



-- INFO


author : Article a -> Author
author (Article internals _) =
    internals.author


metadata : Article a -> Metadata
metadata (Article internals _) =
    internals.metadata


slug : Article a -> Slug
slug (Article internals _) =
    internals.slug


body : Article Full -> Body
body _ =
    "👉 TODO make this return the article's body"



-- TRANSFORM


{-| This is the only way you can transform an existing article:
you can change its author (e.g. to follow or unfollow them).
All other article data necessarily comes from the server!

We can tell this for sure by looking at the types of the exposed functions
in this module.

-}
mapAuthor : (Author -> Author) -> Article a -> Article a
mapAuthor transform (Article info extras) =
    Article { info | author = transform info.author } extras


fromPreview : Body -> Article Preview -> Article Full
fromPreview _ _ =
    "👉 TODO convert from an Article Preview to an Article Full"



-- SERIALIZATION


previewDecoder : Maybe Cred -> Decoder (Article Preview)
previewDecoder maybeCred =
    Decode.succeed Article
        |> custom (internalsDecoder maybeCred)
        |> hardcoded Preview


fullDecoder : Maybe Cred -> Decoder (Article Full)
fullDecoder maybeCred =
    Decode.succeed Article
        |> custom (internalsDecoder maybeCred)
        |> required "body" "👉 TODO use `Body.decoder` (which is a `Decoder Body`) to decode the body into this Article Full"


internalsDecoder : Maybe Cred -> Decoder Internals
internalsDecoder maybeCred =
    Decode.succeed Internals
        |> required "slug" Slug.decoder
        |> required "author" (Author.decoder maybeCred)
        |> custom metadataDecoder


metadataDecoder : Decoder Metadata
metadataDecoder =
    Decode.succeed Metadata
        |> required "description" (Decode.map (Maybe.withDefault "") (Decode.nullable Decode.string))
        |> required "title" Decode.string
        |> required "tagList" (Decode.list Decode.string)
        |> required "createdAt" Timestamp.iso8601Decoder
        |> required "favorited" Decode.bool
        |> required "favoritesCount" Decode.int



-- SINGLE


fetch : Maybe Cred -> Slug -> Http.Request (Article Full)
fetch maybeCred articleSlug =
    let
        expect =
            fullDecoder maybeCred
                |> Decode.field "article"
                |> Http.expectJson
    in
    url articleSlug []
        |> HttpBuilder.get
        |> HttpBuilder.withExpect expect
        |> Cred.addHeaderIfAvailable maybeCred
        |> HttpBuilder.toRequest



-- FAVORITE


favorite : Slug -> Cred -> Http.Request (Article Preview)
favorite articleSlug cred =
    buildFavorite HttpBuilder.post articleSlug cred


unfavorite : Slug -> Cred -> Http.Request (Article Preview)
unfavorite articleSlug cred =
    buildFavorite HttpBuilder.delete articleSlug cred


buildFavorite :
    (String -> RequestBuilder a)
    -> Slug
    -> Cred
    -> Http.Request (Article Preview)
buildFavorite builderFromUrl articleSlug cred =
    let
        expect =
            previewDecoder (Just cred)
                |> Decode.field "article"
                |> Http.expectJson
    in
    builderFromUrl (url articleSlug [ "favorite" ])
        |> Cred.addHeader cred
        |> withExpect expect
        |> HttpBuilder.toRequest


{-| This is a "build your own element" API.

You pass it some configuration, followed by a `List (Attribute msg)` and a
`List (Html msg)`, just like any standard Html element.

-}
favoriteButton : Cred -> msg -> List (Attribute msg) -> List (Html msg) -> Html msg
favoriteButton _ msg attrs kids =
    toggleFavoriteButton "btn btn-sm btn-outline-primary" msg attrs kids


unfavoriteButton : Cred -> msg -> List (Attribute msg) -> List (Html msg) -> Html msg
unfavoriteButton _ msg attrs kids =
    toggleFavoriteButton "btn btn-sm btn-primary" msg attrs kids


toggleFavoriteButton :
    String
    -> msg
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
toggleFavoriteButton classStr msg attrs kids =
    Html.button
        (class classStr :: onClickStopPropagation msg :: attrs)
        (i [ class "ion-heart" ] [] :: kids)


onClickStopPropagation : msg -> Attribute msg
onClickStopPropagation msg =
    stopPropagationOn "click"
        (Decode.succeed ( msg, True ))



-- URLS


url : Slug -> List String -> String
url articleSlug paths =
    allArticlesUrl (Slug.toString articleSlug :: paths)


allArticlesUrl : List String -> String
allArticlesUrl paths =
    Api.url ("articles" :: paths)
