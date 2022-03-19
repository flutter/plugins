// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v2.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package io.flutter.plugins.videoplayer;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/** Generated class from Pigeon. */
@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})
public class Messages {

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class TextureMessage {
    private @NonNull Long textureId;

    public @NonNull Long getTextureId() {
      return textureId;
    }

    public void setTextureId(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"textureId\" is null.");
      }
      this.textureId = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private TextureMessage() {}

    public static class Builder {
      private @Nullable Long textureId;

      public @NonNull Builder setTextureId(@NonNull Long setterArg) {
        this.textureId = setterArg;
        return this;
      }

      public @NonNull TextureMessage build() {
        TextureMessage pigeonReturn = new TextureMessage();
        pigeonReturn.setTextureId(textureId);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("textureId", textureId);
      return toMapResult;
    }

    static @NonNull TextureMessage fromMap(@NonNull Map<String, Object> map) {
      TextureMessage pigeonResult = new TextureMessage();
      Object textureId = map.get("textureId");
      pigeonResult.setTextureId(
          (textureId == null)
              ? null
              : ((textureId instanceof Integer) ? (Integer) textureId : (Long) textureId));
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class LoopingMessage {
    private @NonNull Long textureId;

    public @NonNull Long getTextureId() {
      return textureId;
    }

    public void setTextureId(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"textureId\" is null.");
      }
      this.textureId = setterArg;
    }

    private @NonNull Boolean isLooping;

    public @NonNull Boolean getIsLooping() {
      return isLooping;
    }

    public void setIsLooping(@NonNull Boolean setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"isLooping\" is null.");
      }
      this.isLooping = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private LoopingMessage() {}

    public static class Builder {
      private @Nullable Long textureId;

      public @NonNull Builder setTextureId(@NonNull Long setterArg) {
        this.textureId = setterArg;
        return this;
      }

      private @Nullable Boolean isLooping;

      public @NonNull Builder setIsLooping(@NonNull Boolean setterArg) {
        this.isLooping = setterArg;
        return this;
      }

      public @NonNull LoopingMessage build() {
        LoopingMessage pigeonReturn = new LoopingMessage();
        pigeonReturn.setTextureId(textureId);
        pigeonReturn.setIsLooping(isLooping);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("textureId", textureId);
      toMapResult.put("isLooping", isLooping);
      return toMapResult;
    }

    static @NonNull LoopingMessage fromMap(@NonNull Map<String, Object> map) {
      LoopingMessage pigeonResult = new LoopingMessage();
      Object textureId = map.get("textureId");
      pigeonResult.setTextureId(
          (textureId == null)
              ? null
              : ((textureId instanceof Integer) ? (Integer) textureId : (Long) textureId));
      Object isLooping = map.get("isLooping");
      pigeonResult.setIsLooping((Boolean) isLooping);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class VolumeMessage {
    private @NonNull Long textureId;

    public @NonNull Long getTextureId() {
      return textureId;
    }

    public void setTextureId(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"textureId\" is null.");
      }
      this.textureId = setterArg;
    }

    private @NonNull Double volume;

    public @NonNull Double getVolume() {
      return volume;
    }

    public void setVolume(@NonNull Double setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"volume\" is null.");
      }
      this.volume = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private VolumeMessage() {}

    public static class Builder {
      private @Nullable Long textureId;

      public @NonNull Builder setTextureId(@NonNull Long setterArg) {
        this.textureId = setterArg;
        return this;
      }

      private @Nullable Double volume;

      public @NonNull Builder setVolume(@NonNull Double setterArg) {
        this.volume = setterArg;
        return this;
      }

      public @NonNull VolumeMessage build() {
        VolumeMessage pigeonReturn = new VolumeMessage();
        pigeonReturn.setTextureId(textureId);
        pigeonReturn.setVolume(volume);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("textureId", textureId);
      toMapResult.put("volume", volume);
      return toMapResult;
    }

    static @NonNull VolumeMessage fromMap(@NonNull Map<String, Object> map) {
      VolumeMessage pigeonResult = new VolumeMessage();
      Object textureId = map.get("textureId");
      pigeonResult.setTextureId(
          (textureId == null)
              ? null
              : ((textureId instanceof Integer) ? (Integer) textureId : (Long) textureId));
      Object volume = map.get("volume");
      pigeonResult.setVolume((Double) volume);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class PlaybackSpeedMessage {
    private @NonNull Long textureId;

    public @NonNull Long getTextureId() {
      return textureId;
    }

    public void setTextureId(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"textureId\" is null.");
      }
      this.textureId = setterArg;
    }

    private @NonNull Double speed;

    public @NonNull Double getSpeed() {
      return speed;
    }

    public void setSpeed(@NonNull Double setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"speed\" is null.");
      }
      this.speed = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private PlaybackSpeedMessage() {}

    public static class Builder {
      private @Nullable Long textureId;

      public @NonNull Builder setTextureId(@NonNull Long setterArg) {
        this.textureId = setterArg;
        return this;
      }

      private @Nullable Double speed;

      public @NonNull Builder setSpeed(@NonNull Double setterArg) {
        this.speed = setterArg;
        return this;
      }

      public @NonNull PlaybackSpeedMessage build() {
        PlaybackSpeedMessage pigeonReturn = new PlaybackSpeedMessage();
        pigeonReturn.setTextureId(textureId);
        pigeonReturn.setSpeed(speed);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("textureId", textureId);
      toMapResult.put("speed", speed);
      return toMapResult;
    }

    static @NonNull PlaybackSpeedMessage fromMap(@NonNull Map<String, Object> map) {
      PlaybackSpeedMessage pigeonResult = new PlaybackSpeedMessage();
      Object textureId = map.get("textureId");
      pigeonResult.setTextureId(
          (textureId == null)
              ? null
              : ((textureId instanceof Integer) ? (Integer) textureId : (Long) textureId));
      Object speed = map.get("speed");
      pigeonResult.setSpeed((Double) speed);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class PositionMessage {
    private @NonNull Long textureId;

    public @NonNull Long getTextureId() {
      return textureId;
    }

    public void setTextureId(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"textureId\" is null.");
      }
      this.textureId = setterArg;
    }

    private @NonNull Long position;

    public @NonNull Long getPosition() {
      return position;
    }

    public void setPosition(@NonNull Long setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"position\" is null.");
      }
      this.position = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private PositionMessage() {}

    public static class Builder {
      private @Nullable Long textureId;

      public @NonNull Builder setTextureId(@NonNull Long setterArg) {
        this.textureId = setterArg;
        return this;
      }

      private @Nullable Long position;

      public @NonNull Builder setPosition(@NonNull Long setterArg) {
        this.position = setterArg;
        return this;
      }

      public @NonNull PositionMessage build() {
        PositionMessage pigeonReturn = new PositionMessage();
        pigeonReturn.setTextureId(textureId);
        pigeonReturn.setPosition(position);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("textureId", textureId);
      toMapResult.put("position", position);
      return toMapResult;
    }

    static @NonNull PositionMessage fromMap(@NonNull Map<String, Object> map) {
      PositionMessage pigeonResult = new PositionMessage();
      Object textureId = map.get("textureId");
      pigeonResult.setTextureId(
          (textureId == null)
              ? null
              : ((textureId instanceof Integer) ? (Integer) textureId : (Long) textureId));
      Object position = map.get("position");
      pigeonResult.setPosition(
          (position == null)
              ? null
              : ((position instanceof Integer) ? (Integer) position : (Long) position));
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class CreateMessage {
    private @Nullable String asset;

    public @Nullable String getAsset() {
      return asset;
    }

    public void setAsset(@Nullable String setterArg) {
      this.asset = setterArg;
    }

    private @Nullable String uri;

    public @Nullable String getUri() {
      return uri;
    }

    public void setUri(@Nullable String setterArg) {
      this.uri = setterArg;
    }

    private @Nullable String packageName;

    public @Nullable String getPackageName() {
      return packageName;
    }

    public void setPackageName(@Nullable String setterArg) {
      this.packageName = setterArg;
    }

    private @Nullable String formatHint;

    public @Nullable String getFormatHint() {
      return formatHint;
    }

    public void setFormatHint(@Nullable String setterArg) {
      this.formatHint = setterArg;
    }

    private @NonNull Map<String, String> httpHeaders;

    public @NonNull Map<String, String> getHttpHeaders() {
      return httpHeaders;
    }

    public void setHttpHeaders(@NonNull Map<String, String> setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"httpHeaders\" is null.");
      }
      this.httpHeaders = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private CreateMessage() {}

    public static class Builder {
      private @Nullable String asset;

      public @NonNull Builder setAsset(@Nullable String setterArg) {
        this.asset = setterArg;
        return this;
      }

      private @Nullable String uri;

      public @NonNull Builder setUri(@Nullable String setterArg) {
        this.uri = setterArg;
        return this;
      }

      private @Nullable String packageName;

      public @NonNull Builder setPackageName(@Nullable String setterArg) {
        this.packageName = setterArg;
        return this;
      }

      private @Nullable String formatHint;

      public @NonNull Builder setFormatHint(@Nullable String setterArg) {
        this.formatHint = setterArg;
        return this;
      }

      private @Nullable Map<String, String> httpHeaders;

      public @NonNull Builder setHttpHeaders(@NonNull Map<String, String> setterArg) {
        this.httpHeaders = setterArg;
        return this;
      }

      public @NonNull CreateMessage build() {
        CreateMessage pigeonReturn = new CreateMessage();
        pigeonReturn.setAsset(asset);
        pigeonReturn.setUri(uri);
        pigeonReturn.setPackageName(packageName);
        pigeonReturn.setFormatHint(formatHint);
        pigeonReturn.setHttpHeaders(httpHeaders);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("asset", asset);
      toMapResult.put("uri", uri);
      toMapResult.put("packageName", packageName);
      toMapResult.put("formatHint", formatHint);
      toMapResult.put("httpHeaders", httpHeaders);
      return toMapResult;
    }

    static @NonNull CreateMessage fromMap(@NonNull Map<String, Object> map) {
      CreateMessage pigeonResult = new CreateMessage();
      Object asset = map.get("asset");
      pigeonResult.setAsset((String) asset);
      Object uri = map.get("uri");
      pigeonResult.setUri((String) uri);
      Object packageName = map.get("packageName");
      pigeonResult.setPackageName((String) packageName);
      Object formatHint = map.get("formatHint");
      pigeonResult.setFormatHint((String) formatHint);
      Object httpHeaders = map.get("httpHeaders");
      pigeonResult.setHttpHeaders((Map<String, String>) httpHeaders);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class MixWithOthersMessage {
    private @NonNull Boolean mixWithOthers;

    public @NonNull Boolean getMixWithOthers() {
      return mixWithOthers;
    }

    public void setMixWithOthers(@NonNull Boolean setterArg) {
      if (setterArg == null) {
        throw new IllegalStateException("Nonnull field \"mixWithOthers\" is null.");
      }
      this.mixWithOthers = setterArg;
    }

    /** Constructor is private to enforce null safety; use Builder. */
    private MixWithOthersMessage() {}

    public static class Builder {
      private @Nullable Boolean mixWithOthers;

      public @NonNull Builder setMixWithOthers(@NonNull Boolean setterArg) {
        this.mixWithOthers = setterArg;
        return this;
      }

      public @NonNull MixWithOthersMessage build() {
        MixWithOthersMessage pigeonReturn = new MixWithOthersMessage();
        pigeonReturn.setMixWithOthers(mixWithOthers);
        return pigeonReturn;
      }
    }

    @NonNull
    Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("mixWithOthers", mixWithOthers);
      return toMapResult;
    }

    static @NonNull MixWithOthersMessage fromMap(@NonNull Map<String, Object> map) {
      MixWithOthersMessage pigeonResult = new MixWithOthersMessage();
      Object mixWithOthers = map.get("mixWithOthers");
      pigeonResult.setMixWithOthers((Boolean) mixWithOthers);
      return pigeonResult;
    }
  }

  private static class AndroidVideoPlayerApiCodec extends StandardMessageCodec {
    public static final AndroidVideoPlayerApiCodec INSTANCE = new AndroidVideoPlayerApiCodec();

    private AndroidVideoPlayerApiCodec() {}

    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte) 128:
          return CreateMessage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte) 129:
          return LoopingMessage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte) 130:
          return MixWithOthersMessage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte) 131:
          return PlaybackSpeedMessage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte) 132:
          return PositionMessage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte) 133:
          return TextureMessage.fromMap((Map<String, Object>) readValue(buffer));

        case (byte) 134:
          return VolumeMessage.fromMap((Map<String, Object>) readValue(buffer));

        default:
          return super.readValueOfType(type, buffer);
      }
    }

    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value) {
      if (value instanceof CreateMessage) {
        stream.write(128);
        writeValue(stream, ((CreateMessage) value).toMap());
      } else if (value instanceof LoopingMessage) {
        stream.write(129);
        writeValue(stream, ((LoopingMessage) value).toMap());
      } else if (value instanceof MixWithOthersMessage) {
        stream.write(130);
        writeValue(stream, ((MixWithOthersMessage) value).toMap());
      } else if (value instanceof PlaybackSpeedMessage) {
        stream.write(131);
        writeValue(stream, ((PlaybackSpeedMessage) value).toMap());
      } else if (value instanceof PositionMessage) {
        stream.write(132);
        writeValue(stream, ((PositionMessage) value).toMap());
      } else if (value instanceof TextureMessage) {
        stream.write(133);
        writeValue(stream, ((TextureMessage) value).toMap());
      } else if (value instanceof VolumeMessage) {
        stream.write(134);
        writeValue(stream, ((VolumeMessage) value).toMap());
      } else {
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter. */
  public interface AndroidVideoPlayerApi {
    void initialize();

    @NonNull
    TextureMessage create(@NonNull CreateMessage msg);

    void dispose(@NonNull TextureMessage msg);

    void setLooping(@NonNull LoopingMessage msg);

    void setVolume(@NonNull VolumeMessage msg);

    void setPlaybackSpeed(@NonNull PlaybackSpeedMessage msg);

    void play(@NonNull TextureMessage msg);

    @NonNull
    PositionMessage position(@NonNull TextureMessage msg);

    void seekTo(@NonNull PositionMessage msg);

    void pause(@NonNull TextureMessage msg);

    void setMixWithOthers(@NonNull MixWithOthersMessage msg);

    /** The codec used by AndroidVideoPlayerApi. */
    static MessageCodec<Object> getCodec() {
      return AndroidVideoPlayerApiCodec.INSTANCE;
    }

    /**
     * Sets up an instance of `AndroidVideoPlayerApi` to handle messages through the
     * `binaryMessenger`.
     */
    static void setup(BinaryMessenger binaryMessenger, AndroidVideoPlayerApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.initialize", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  api.initialize();
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.create", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  CreateMessage msgArg = (CreateMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  TextureMessage output = api.create(msgArg);
                  wrapped.put("result", output);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.dispose", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  TextureMessage msgArg = (TextureMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.dispose(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.setLooping", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  LoopingMessage msgArg = (LoopingMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.setLooping(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.setVolume", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  VolumeMessage msgArg = (VolumeMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.setVolume(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.AndroidVideoPlayerApi.setPlaybackSpeed",
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  PlaybackSpeedMessage msgArg = (PlaybackSpeedMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.setPlaybackSpeed(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.play", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  TextureMessage msgArg = (TextureMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.play(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.position", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  TextureMessage msgArg = (TextureMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  PositionMessage output = api.position(msgArg);
                  wrapped.put("result", output);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.seekTo", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  PositionMessage msgArg = (PositionMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.seekTo(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger, "dev.flutter.pigeon.AndroidVideoPlayerApi.pause", getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  TextureMessage msgArg = (TextureMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.pause(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(
                binaryMessenger,
                "dev.flutter.pigeon.AndroidVideoPlayerApi.setMixWithOthers",
                getCodec());
        if (api != null) {
          channel.setMessageHandler(
              (message, reply) -> {
                Map<String, Object> wrapped = new HashMap<>();
                try {
                  ArrayList<Object> args = (ArrayList<Object>) message;
                  MixWithOthersMessage msgArg = (MixWithOthersMessage) args.get(0);
                  if (msgArg == null) {
                    throw new NullPointerException("msgArg unexpectedly null.");
                  }
                  api.setMixWithOthers(msgArg);
                  wrapped.put("result", null);
                } catch (Error | RuntimeException exception) {
                  wrapped.put("error", wrapError(exception));
                }
                reply.reply(wrapped);
              });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }

  private static Map<String, Object> wrapError(Throwable exception) {
    Map<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", exception.toString());
    errorMap.put("code", exception.getClass().getSimpleName());
    errorMap.put(
        "details",
        "Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
    return errorMap;
  }
}
