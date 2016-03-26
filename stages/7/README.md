Stage 7
=======

## Installation

```bash
elm package install
```

(Answer `y` at the prompt. In rare cases a known issue can cause the download
to fail; in that case, just run `elm package install` again.)

## Building

```bash
elm live Main.elm --open -- --output=elm.js
```

## Running Tests

```bash
cd test
elm package install
elm test TestRunner.elm
```
