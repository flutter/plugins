## 2.3.2

* Applies the standardized transform for videos with different orientations.

## 2.3.1

* Renames internal method channels to avoid potential confusion with the
  default implementation's method channel.
* Updates Pigeon to 2.0.1.

## 2.3.0

* Updates Pigeon to ^1.0.16.

## 2.2.18

* Wait to initialize m3u8 videos until size is set, fixing aspect ratio.
* Adjusts test timeouts for network-dependent native tests to avoid flake.

## 2.2.17

* Splits from `video_player` as a federated implementation.
