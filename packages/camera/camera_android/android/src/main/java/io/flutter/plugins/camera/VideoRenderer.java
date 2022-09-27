// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static android.os.SystemClock.uptimeMillis;

import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLExt;
import android.opengl.EGLSurface;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLUtils;
import android.opengl.Matrix;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

/** Renders video onto texture */
public class VideoRenderer {

  private static String TAG = "VideoRenderer";

  private static final String vertexShaderCode =
      "  precision highp float;\n"
          + "            attribute vec3 vertexPosition;\n"
          + "            attribute vec2 uvs;\n"
          + "            varying vec2 varUvs;\n"
          + "            uniform mat4 texMatrix;\n"
          + "            uniform mat4 mvp;\n"
          + "\n"
          + "            void main()\n"
          + "            {\n"
          + "                varUvs = (texMatrix * vec4(uvs.x, uvs.y, 0, 1.0)).xy;\n"
          + "                gl_Position = mvp * vec4(vertexPosition, 1.0);\n"
          + "            }";

  private static final String fragmentShaderCode =
      " #extension GL_OES_EGL_image_external : require\n"
          + "            precision mediump float;\n"
          + "\n"
          + "            varying vec2 varUvs;\n"
          + "            uniform samplerExternalOES texSampler;\n"
          + "\n"
          + "            void main()\n"
          + "            {\n"
          + "                vec4 c = texture2D(texSampler, varUvs);\n"
          + "                gl_FragColor = vec4(c.r, c.g, c.b, c.a);\n"
          + "            }";

  private final int[] textureHandles = new int[1];

  private final float[] vertices =
      new float[] {
        -1.0f, -1.0f, 0.0f, 0f, 0f, -1.0f, 1.0f, 0.0f, 0f, 1f, 1.0f, 1.0f, 0.0f, 1f, 1f, 1.0f,
        -1.0f, 0.0f, 1f, 0f
      };

  private final int[] indices = new int[] {2, 1, 0, 0, 3, 2};

  private int program;
  private int vertexHandle = 0;
  private final int[] bufferHandles = new int[2];
  private int uvsHandle = 0;
  private int texMatrixHandle = 0;
  private int mvpHandle = 0;

  EGLDisplay display;
  EGLContext context;
  EGLSurface surface;
  private Thread thread;
  private final Surface outputSurface;
  private SurfaceTexture inputSurfaceTexture;
  private Surface inputSurface;

  private HandlerThread surfaceTextureFrameAvailableHandler;
  private final Object surfaceTextureAvailableFrameLock = new Object();
  private Boolean surfaceTextureFrameAvailable = false;

  private final int recordingWidth;
  private final int recordingHeight;
  private int rotation = 0;

  private final Object lock = new Object();

  /** Gets surface for input. Blocks until surface is ready */
  public Surface getInputSurface() throws InterruptedException {
    synchronized (lock) {
      while (inputSurface == null) {
        lock.wait();
      }
    }
    return inputSurface;
  }

  public VideoRenderer(Surface outputSurface, int recordingWidth, int recordingHeight) {
    this.outputSurface = outputSurface;
    this.recordingHeight = recordingHeight;
    this.recordingWidth = recordingWidth;
    startOpenGL();
    Log.d(TAG, "VideoRenderer setup complete");
  }

  /** Stop rendering and cleanup resources */
  public void close() {
    thread.interrupt();
    surfaceTextureFrameAvailableHandler.quitSafely();
    inputSurfaceTexture.release();
  }

  /** Configures openGL. must be called in same thread as draw is called */
  private void configureOpenGL() {
    synchronized (lock) {
      display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
      if (display == EGL14.EGL_NO_DISPLAY)
        throw new RuntimeException(
            "eglDisplay == EGL14.EGL_NO_DISPLAY: "
                + GLUtils.getEGLErrorString(EGL14.eglGetError()));

      int[] version = new int[2];
      if (!EGL14.eglInitialize(display, version, 0, version, 1))
        throw new RuntimeException(
            "eglInitialize(): " + GLUtils.getEGLErrorString(EGL14.eglGetError()));

      int[] attribList =
          new int[] {
            EGL14.EGL_RED_SIZE, 8,
            EGL14.EGL_GREEN_SIZE, 8,
            EGL14.EGL_BLUE_SIZE, 8,
            EGL14.EGL_ALPHA_SIZE, 8,
            EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
            EGLExt.EGL_RECORDABLE_ANDROID, 1,
            EGL14.EGL_NONE
          };

      EGLConfig[] configs = new EGLConfig[1];
      int[] numConfigs = new int[1];
      if (!EGL14.eglChooseConfig(display, attribList, 0, configs, 0, configs.length, numConfigs, 0))
        throw new RuntimeException(GLUtils.getEGLErrorString(EGL14.eglGetError()));

      int err = EGL14.eglGetError();
      if (err != EGL14.EGL_SUCCESS) throw new RuntimeException(GLUtils.getEGLErrorString(err));

      int[] ctxAttribs = new int[] {EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE};
      context = EGL14.eglCreateContext(display, configs[0], EGL14.EGL_NO_CONTEXT, ctxAttribs, 0);

      err = EGL14.eglGetError();
      if (err != EGL14.EGL_SUCCESS) throw new RuntimeException(GLUtils.getEGLErrorString(err));

      int[] surfaceAttribs = new int[] {EGL14.EGL_NONE};

      surface = EGL14.eglCreateWindowSurface(display, configs[0], outputSurface, surfaceAttribs, 0);

      err = EGL14.eglGetError();
      if (err != EGL14.EGL_SUCCESS) throw new RuntimeException(GLUtils.getEGLErrorString(err));

      if (!EGL14.eglMakeCurrent(display, surface, surface, context))
        throw new RuntimeException(
            "eglMakeCurrent(): " + GLUtils.getEGLErrorString(EGL14.eglGetError()));

      ByteBuffer vertexBuffer = ByteBuffer.allocateDirect(vertices.length * 4);
      vertexBuffer.order(ByteOrder.nativeOrder());
      vertexBuffer.asFloatBuffer().put(vertices);
      vertexBuffer.asFloatBuffer().position(0);

      ByteBuffer indexBuffer = ByteBuffer.allocateDirect(indices.length * 4);
      indexBuffer.order(ByteOrder.nativeOrder());
      indexBuffer.asIntBuffer().put(indices);
      indexBuffer.position(0);

      int vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexShaderCode);
      int fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShaderCode);

      program = GLES20.glCreateProgram();

      GLES20.glAttachShader(program, vertexShader);
      GLES20.glAttachShader(program, fragmentShader);
      GLES20.glLinkProgram(program);

      vertexHandle = GLES20.glGetAttribLocation(program, "vertexPosition");
      uvsHandle = GLES20.glGetAttribLocation(program, "uvs");
      texMatrixHandle = GLES20.glGetUniformLocation(program, "texMatrix");
      mvpHandle = GLES20.glGetUniformLocation(program, "mvp");

      // Initialize buffers
      GLES20.glGenBuffers(2, bufferHandles, 0);

      GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, bufferHandles[0]);
      GLES20.glBufferData(
          GLES20.GL_ARRAY_BUFFER, vertices.length * 4, vertexBuffer, GLES20.GL_DYNAMIC_DRAW);

      GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, bufferHandles[1]);
      GLES20.glBufferData(
          GLES20.GL_ELEMENT_ARRAY_BUFFER, indices.length * 4, indexBuffer, GLES20.GL_DYNAMIC_DRAW);

      // Init texture that will receive decoded frames
      GLES20.glGenTextures(1, textureHandles, 0);
      GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureHandles[0]);

      inputSurfaceTexture = new SurfaceTexture(getTexId());
      inputSurfaceTexture.setDefaultBufferSize(recordingWidth, recordingHeight);
      surfaceTextureFrameAvailableHandler = new HandlerThread("FrameHandlerThread");
      surfaceTextureFrameAvailableHandler.start();
      inputSurface = new Surface(inputSurfaceTexture);

      inputSurfaceTexture.setOnFrameAvailableListener(
          new SurfaceTexture.OnFrameAvailableListener() {
            @Override
            public void onFrameAvailable(SurfaceTexture surfaceTexture) {
              synchronized (surfaceTextureAvailableFrameLock) {
                if (surfaceTextureFrameAvailable)
                  Log.w(TAG, "Frame available before processing other frames. dropping frames");
                surfaceTextureFrameAvailable = true;
                surfaceTextureAvailableFrameLock.notifyAll();
              }
            }
          },
          new Handler(surfaceTextureFrameAvailableHandler.getLooper()));
      lock.notifyAll();
    }
  }

  /** Starts and configures Video Renderer */
  private void startOpenGL() {
    Log.d(TAG, "Starting OpenGL Thread");
    thread =
        new Thread() {
          @Override
          public void run() {

            configureOpenGL();

            try {
              // continuously pull frames from input surface texture and use videoRenderer to modify
              // to correct rotation
              while (!Thread.interrupted()) {

                synchronized (surfaceTextureAvailableFrameLock) {
                  while (!surfaceTextureFrameAvailable) {
                    surfaceTextureAvailableFrameLock.wait(500);
                  }
                  surfaceTextureFrameAvailable = false;
                }

                inputSurfaceTexture.updateTexImage();

                float[] surfaceTextureMatrix = new float[16];
                inputSurfaceTexture.getTransformMatrix(surfaceTextureMatrix);

                draw(
                    recordingWidth,
                    recordingHeight,
                    surfaceTextureMatrix,
                    inputSurfaceTexture.getTimestamp());
              }
            } catch (InterruptedException e) {
              Log.d(TAG, "thread interrupted while waiting for frames");
            }
          }
        };
    thread.start();
  }

  public int getTexId() {
    return textureHandles[0];
  }

  public float[] moveMatrix() {
    float[] m = new float[16];
    Matrix.setIdentityM(m, 0);
    Matrix.rotateM(m, 0, rotation, 0, 0, 1);
    return m;
  }

  public void setRotation(int rotation) {
    this.rotation = rotation;
  }

  private int loadShader(int type, String code) {

    int shader = GLES20.glCreateShader(type);

    GLES20.glShaderSource(shader, code);
    GLES20.glCompileShader(shader);
    return shader;
  }

  public void draw(int viewportWidth, int viewportHeight, float[] texMatrix, long timestamp) {

    GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
    GLES20.glClearColor(0f, 0f, 0f, 0f);

    GLES20.glViewport(0, 0, viewportWidth, viewportHeight);

    GLES20.glUseProgram(program);

    // Pass transformations to shader
    GLES20.glUniformMatrix4fv(texMatrixHandle, 1, false, texMatrix, 0);
    GLES20.glUniformMatrix4fv(mvpHandle, 1, false, moveMatrix(), 0);

    // Prepare buffers with vertices and indices & draw
    GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, bufferHandles[0]);
    GLES20.glBindBuffer(GLES20.GL_ELEMENT_ARRAY_BUFFER, bufferHandles[1]);

    GLES20.glEnableVertexAttribArray(vertexHandle);
    GLES20.glVertexAttribPointer(vertexHandle, 3, GLES20.GL_FLOAT, false, 4 * 5, 0);

    GLES20.glEnableVertexAttribArray(uvsHandle);
    GLES20.glVertexAttribPointer(uvsHandle, 2, GLES20.GL_FLOAT, false, 4 * 5, 3 * 4);

    GLES20.glDrawElements(GLES20.GL_TRIANGLES, 6, GLES20.GL_UNSIGNED_INT, 0);

    EGLExt.eglPresentationTimeANDROID(
        display, surface, uptimeMillis() * 1000000); // Not the perfect solution but works well, see
    // https://stackoverflow.com/questions/63467704/mediarecorder-surface-input-with-opengl-issue-if-audio-recording-is-enabled TODO: try on more devices and see if the timestamp can be incorporated
    EGL14.eglSwapBuffers(display, surface);
  }
}
