# video_player_web

The web implementation of [`video_player`][1].

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `video_player` normally. This package will be
automatically included in your app when you do.

## Limitations on the Web platform

Video playback on the Web platform has some limitations that might surprise developers
more familiar with mobile/desktop targets.

In no particular order:

### dart:io

The web platform does **not** suppport `dart:io`, so attempts to create a `VideoPlayerController.file`
will throw an `UnimplementedError`.

### Autoplay

Attempts to start playing videos with an audio track (or not muted) without user
interaction with the site ("user activation") will be prohibited by the browser
and cause runtime errors in JS.

See also:

* [Autoplay policy in Chrome](https://developer.chrome.com/blog/autoplay/)
* MDN > [Autoplay guide for media and Web Audio APIs](https://developer.mozilla.org/en-US/docs/Web/Media/Autoplay_guide)
* Delivering Video Content for Safari > [Enable Video Autoplay](https://developer.apple.com/documentation/webkit/delivering_video_content_for_safari#3030251)
* More info about "user activation", in general:
  * [Making user activation consistent across APIs](https://developer.chrome.com/blog/user-activation)
  * HTML Spec: [Tracking user activation](https://html.spec.whatwg.org/multipage/interaction.html#sticky-activation)

### Some videos restart when using the seek bar/progress bar/scrubber

Certain videos will rewind to the beginning when users attempt to `seekTo` (change
the progress/scrub to) another position, instead of jumping to the desired position.
Once the video is fully stored in the browser cache, seeking will work fine after
a full page reload.

The most common explanation for this issue is that the server where the video is
stored doesn't support [HTTP range requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests).

> **NOTE:** Flutter web's local server (the one that powers `flutter run`) **DOES NOT** support
> range requests, so all video **assets** in `debug` mode will exhibit this behavior.

See [Issue #49360](https://github.com/flutter/flutter/issues/49360) for more information
on how to diagnose if a server supports range requests or not.

### Mixing audio with other audio sources

The `VideoPlayerOptions.mixWithOthers` option can't be implemented in web, at least
at the moment. If you use this option it will be silently ignored.

## Supported Formats

**Different web browsers support different sets of video codecs.**

### Video codecs?

Check MDN's [**Web video codec guide**](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Video_codecs)
to learn more about the pros and cons of each video codec.

### What codecs are supported?

Visit [**caniuse.com: 'video format'**](https://caniuse.com/#search=video%20format)
for a breakdown of which browsers support what codecs. You can customize charts
there for the users of your particular website(s).

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
