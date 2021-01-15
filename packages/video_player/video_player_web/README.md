# video_player_web

The web implementation of [`video_player`][1].


**Please set your constraint to `video_player_web: '>=0.1.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.1.y+z`.
Please use `video_player_web: '>=0.1.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

## Usage

This package is the endorsed implementation of `video_player` for the web platform since version `0.10.5`, so it gets automatically added to your application by depending on `video_player: ^0.10.5`.

No further modifications to your `pubspec.yaml` should be required in a recent enough version of Flutter (`>=1.12.13+hotfix.4`):

```yaml
...
dependencies:
  ...
  video_player: ^0.10.5
  ...
```

Once you have the correct `video_player` dependency in your pubspec, you should
be able to use `package:video_player` as normal, even from your web code.

## dart:io

The Web platform does **not** suppport `dart:io`, so attempts to create a `VideoPlayerController.file` will throw an `UnimplementedError`.

## Autoplay
Playing videos without prior interaction with the site might be prohibited
by the browser and lead to runtime errors. See also: https://goo.gl/xX8pDD.

## Supported Formats

**Different web browsers support different sets of video codecs.**

### Video codecs?

Check MDN's [**Web video codec guide**](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Video_codecs) to learn more about the pros and cons of each video codec.

### What codecs are supported?

Visit [**caniuse.com: 'video format'**](https://caniuse.com/#search=video%20format) for a breakdown of which browsers support what codecs. You can customize charts there for the users of your particular website(s).

Here's an abridged version of the data from caniuse, for a Global audience:

#### MPEG-4/H.264
[![Data on Global support for the MPEG-4/H.264 video format](https://caniuse.bitsofco.de/image/mpeg4.png)](https://caniuse.com/#feat=mpeg4)

#### WebM
[![Data on Global support for the WebM video format](https://caniuse.bitsofco.de/image/webm.png)](https://caniuse.com/#feat=webm)

#### Ogg/Theora
[![Data on Global support for the Ogg/Theora video format](https://caniuse.bitsofco.de/image/ogv.png)](https://caniuse.com/#feat=ogv)

#### AV1
[![Data on Global support for the AV1 video format](https://caniuse.bitsofco.de/image/av1.png)](https://caniuse.com/#feat=av1)

#### HEVC/H.265
[![Data on Global support for the HEVC/H.265 video format](https://caniuse.bitsofco.de/image/hevc.png)](https://caniuse.com/#feat=hevc)


[1]: ../video_player
