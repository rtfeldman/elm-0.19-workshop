module Article exposing (feed, tags)

-- For now, this module only holds hardcoded data.
--
-- In future exercises, it will read data from the server!


tags =
    [ "elm"
    , "fun"
    , "programming"
    , "dragons"
    ]


feed =
    [ { title = "Elm is fun!", description = "Elm", body = "I've really been enjoying it!", tags = [ "elm", "fun" ], slug = "elm-is-fun--zb6nba" }
    , { title = "Who says undefined isn't a function anyway?", description = "Functions", body = "Quite frankly I think undefined can be anything it wants to be,if it believes in itself.", slug = "who-says-undefined-isnt-a-function-anyway-t39ope", tags = [ "programming" ] }
    , { title = "This compiler is pretty neat", description = "Elm", body = "It tells me about problems in my code. How neat is that?", tags = [ "compilers", "elm" ], slug = "this-compiler-is-pretty-neat-9ycui8" }
    , { title = "Are dragons real?", description = "dragons", body = "Do Komodo Dragons count? I think they should. It's right there in the name!", tags = [ "dragons" ], slug = "are-dragons-real-467lsh" }
    ]
