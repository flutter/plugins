# video_player_web

The web implementation of [`video_player`][1].

## Usage

To use this plugin in your Flutter Web app, simply add it as a dependency in
your pubspec using a `git` dependency. This is only temporary: in the future
we hope to make this package an "endorsed" implementation of `video_player`,
so that it is automatically included in your Flutter Web app when you depend
on `package:video_player`.

```yaml
dependencies:
  video_player: ^0.10.4
  video_player_web:
    git:
      url: git://github.com/flutter/plugins.git
      path: packages/video_player/video_player_web
```

Once you have the `video_player_web` dependency in your pubspec, you should
be able to use `package:video_player` as normal.

## Autoplay
Playing videos without prior interaction with the site might be prohibited
by the browser and lead to runtime errors. See also: https://goo.gl/xX8pDD.

[1]: ../video_player