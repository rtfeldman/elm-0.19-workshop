### 5.2.0

#### Additions

- `withBearerToken`: add an `Authorization: Bearer ` header (@amarantedaniel)
- `withExpectJson`: shortcut for using `Http.expectJson` (@dbottisti)
- `withExpectString`: shortcut for using `Http.expectString` (@dbottisti)

#### Stuff

- Upgrade `elm-test`
- Remove my old Twitter handle from README

### 5.0.0

This release accomplishes two goals.

1. The `RequestBuilder` type is no longer opaque. This comes after observing
much debate in the community over the merits and drawbacks of hiding details of
a library's types from the user. In this case I have determined it no longer
makes sense to do so. If `RequestBuilder` is opaque and so is `Http.Request`,
there is no longer any opportunity to do introspection, write tests, or create
tooling around the `RequestBuilder` type. So we simply expose the internal
structure of `RequestBuilder` as a record.

2. We're taking over the `send` function again. Thanks to a pull request by @s60
I am convinced that this will be okay. We can still have the same signature for
`send`, and then use tasks inside of `send` to mess around and do extra stuff.
This will just require that the docs for `toRequest` be very clear that it is
lossy with respect to `HttpBuilder` features. So far there is one new feature
that is being brought over from the previous versions, `withCacheBuster`. This
will be a foundation for bringing back other stuff and adding new things as
well.

#### Removals

_None_

#### Breaking Changes

- `RequestBuilder a` is no longer opaque

#### Additions

- `toTask`: Convert your `RequestBuilder a` into a `Task Http.Error a` with all
the extras that `HttpBuilder` has and will have to offer.
- `withCacheBuster`: append a cache buster query param with the current
timestamp to your request's URL.

---

### 4.0.0

A lot has happened since 3.0.0! The API is smaller, and more focused and I'm
excited about that. In particular, `BodyReader` and its friends have been
removed. Since this is the official upgrade for Elm 0.18, the new
`elm-lang/http` package has a lot of influence. The new `Http` package includes
a much more cohesive experience for declaring expectations of response bodies.
[See the `Http.Expect` type in `elm-lang/http`](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http#Expect).
This feature is even reminiscent of `BodyReader`!

Since we have this as a part of the platform now, all of the `BodyReader`-
related features are gone. For these you'll just "use the platform", as they
say, and make use of `withExpect` in your builder pipelines. In the future
we may include fancier, custom `Expect` formulations for your convenience.

Secondly, you'll now have the option to convert a `RequestBuilder a` into an
`Http.Request a` or send it directly using `HttpBuilder.send`, which has the
same signature as `Http.send`. This helps to keep your builder pipelines clean
while also leaving you the option to get out an `Http.Request` if you need.

Long story short, `HttpBuilder` is _just_ about building requests, just like
when it started out. The platform covers the rest.

Here's the list of all changes:

#### Removals
- `url`: use `withQueryParams` instead to add query params to your url
- `withBody`: use one of the more specific `with*Body` functions instead
- `withMultipartBody`: string multipart bodies are the only type supported by
  `elm-lang/http` currently, sojust use `withMultipartStringBody` instead
- `withMimeType`: the first parameter to `withStringBody` will set your MIME
  type automatically. Alternatively, set a header with `withHeader`
- `withCacheBuster`: since we're giving up control of the send process, we can't
  chain on a `Task` to get the current time
- `withZeroStatusAllowed`: we don't control the send process. You can handle
  this yourself under the `Http.BadStatus` error when you deal with errors in
  your send msg tagger.
- `BodyReader`: see intro
- `stringReader`: see intro
- `jsonReader`: see intro
- `unitReader`: see intro
- `Error`: since we don't control the send process we don't need this
- `Response`: same as `Error`
- `toSettings`: `Http.Settings` doesn't exist anymore, it was moved under
  `Http.Request`
- `Request`: since we expect you'll need to import `Http` now anyway, you can
  just import this from `Http`
- `Settings`: see `toSettings`


#### Breaking Changes
- `RequestBuilder` -> `RequestBuilder a`, where the type parameter is the
  expected type of the returned payload.
- `get`, `post`, etc. return `RequestBuilder ()`. The default is to make no
  attempt to decode anything, so it is `()`. You can use `withExpect` to attach
  an `Http.Expect MyType`, which will turn it into a `RequestBuilder MyType`.
- `toRequest` returns an `Http.Request a`
- `send` wraps `Http.send`, [read up on it to see how it works](http://package.elm-lang.org/packages/elm-lang/http/1.0.0/Http#send).


#### Additions
- `withExpect`: attach an `Http.Expect` to the request
- `withQueryParams`: decorate the URL with query params

A sincere thank you to @evancz, @rtfeldman, @bogdanp, and @knewter for time and
discussions that helped me make the decisions that led to these changes!

And a shoutout to @prikhi for taking the time to update the existing API for
0.18 and publishing it as [priki/elm-http-builder](http://package.elm-lang.org/packages/prikhi/elm-http-builder/latest).
