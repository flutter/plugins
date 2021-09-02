// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Handler;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executor;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentMatchers;
import org.mockito.MockedStatic;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

public class HttpRequestManagerTest {

  Executor mockExecutor;
  Handler mockHandler;
  HttpRequestManager httpRequestManager;
  MockedStatic<HttpRequestManager.URLFactory> mockedURLFactory;
  URL mockUrl;
  MockedStatic<HttpRequestManager.BufferedOutputStreamFactory> mockedBufferedOutputStreamFactory;
  BufferedOutputStream mockBufferedOutputStream;
  MockedStatic<HttpRequestManager.BufferedReaderFactory> mockedBufferedReaderFactory;
  BufferedReader mockBufferedReader = mock(BufferedReader.class);
  MockedStatic<HttpRequestManager.InputStreamReaderFactory> mockedInputStreamReaderFactory;
  InputStreamReader mockInputStreamReader = mock(InputStreamReader.class);

  @Before
  public void setup() {
    mockExecutor = mock(Executor.class);
    mockHandler = mock(Handler.class);
    httpRequestManager = spy(new HttpRequestManager(mockExecutor, mockHandler));

    mockUrl = mock(URL.class);
    mockedURLFactory = mockStatic(HttpRequestManager.URLFactory.class);
    mockedURLFactory
        .when(() -> HttpRequestManager.URLFactory.create(ArgumentMatchers.<String>any()))
        .thenReturn(mockUrl);

    mockBufferedOutputStream = mock(BufferedOutputStream.class);
    mockedBufferedOutputStreamFactory =
        mockStatic(HttpRequestManager.BufferedOutputStreamFactory.class);
    mockedBufferedOutputStreamFactory
        .when(
            () ->
                HttpRequestManager.BufferedOutputStreamFactory.create(
                    ArgumentMatchers.<OutputStream>any()))
        .thenReturn(mockBufferedOutputStream);

    mockBufferedReader = mock(BufferedReader.class);
    mockedBufferedReaderFactory = mockStatic(HttpRequestManager.BufferedReaderFactory.class);
    mockedBufferedReaderFactory
        .when(
            () ->
                HttpRequestManager.BufferedReaderFactory.create(
                    ArgumentMatchers.<InputStreamReader>any()))
        .thenReturn(mockBufferedReader);

    mockInputStreamReader = mock(InputStreamReader.class);
    mockedInputStreamReaderFactory = mockStatic(HttpRequestManager.InputStreamReaderFactory.class);
    mockedInputStreamReaderFactory
        .when(
            () ->
                HttpRequestManager.InputStreamReaderFactory.create(
                    ArgumentMatchers.<InputStream>any()))
        .thenReturn(mockInputStreamReader);
  }

  @After
  public void tearDown() {
    mockedURLFactory.close();
    mockedBufferedOutputStreamFactory.close();
    mockedBufferedReaderFactory.close();
    mockedInputStreamReaderFactory.close();
  }

  @Test
  public void request_shouldBuildAndExecuteRequest() throws IOException {
    // Preparation
    WebViewRequest request = mock(WebViewRequest.class);
    Map<String, String> headers =
        new HashMap<String, String>() {
          {
            put("3", "3");
          }
        };
    when(request.getUrl()).thenReturn("1");
    when(request.getBody()).thenReturn(new byte[] {0x02});
    when(request.getMethod()).thenReturn(WebViewLoadMethod.POST);
    when(request.getHeaders()).thenReturn(headers);
    HttpURLConnection mockConnection = mock(HttpURLConnection.class);
    when(mockUrl.openConnection()).thenReturn(mockConnection);
    InputStream mockInputStream = mock(InputStream.class);
    when(mockConnection.getInputStream()).thenReturn(mockInputStream);
    when(mockBufferedReader.readLine())
        .thenAnswer(
            new Answer<String>() {
              private int count = 0;

              public String answer(InvocationOnMock invocation) {
                if (count++ == 3) {
                  return null;
                }
                return "*";
              }
            });

    // Execute
    String resp = httpRequestManager.request(request);

    // Validation
    mockedURLFactory.verify(() -> HttpRequestManager.URLFactory.create("1"));
    // Verify setting of basic request properties
    verify(mockConnection, times(1)).setConnectTimeout(5000);
    verify(mockConnection, times(1)).setRequestMethod("post");
    // Verify header is being set
    verify(mockConnection, times(1)).setRequestProperty("3", "3");
    // Verify request body is set
    verify(mockConnection, times(1)).setFixedLengthStreamingMode(1);
    verify(mockConnection, times(1)).setDoOutput(true);
    verify(mockBufferedOutputStream, times(1)).write(new byte[] {0x02}, 0, 1);
    verify(mockBufferedOutputStream, times(1)).flush();
    // Verify response body is being collected and returned
    mockedInputStreamReaderFactory.verify(
        () -> HttpRequestManager.InputStreamReaderFactory.create(mockInputStream));
    mockedBufferedReaderFactory.verify(
        () -> HttpRequestManager.BufferedReaderFactory.create(mockInputStreamReader));
    verify(mockBufferedReader, times(4)).readLine();
    assertEquals("***", resp);
    // Verify cleanup
    verify(mockConnection, times(1)).disconnect();
  }

  @Test
  public void request_shouldNotSetHeadersWhenNoneAreProvided() throws IOException {
    // Preparation
    WebViewRequest request = mock(WebViewRequest.class);
    when(request.getUrl()).thenReturn("1");
    when(request.getBody()).thenReturn(new byte[] {0x02});
    when(request.getMethod()).thenReturn(WebViewLoadMethod.POST);
    when(request.getHeaders()).thenReturn(Collections.emptyMap());
    HttpURLConnection mockConnection = mock(HttpURLConnection.class);
    when(mockUrl.openConnection()).thenReturn(mockConnection);

    // Execute
    httpRequestManager.request(request);

    // Validation
    verify(mockConnection, never()).setRequestProperty(anyString(), anyString());
  }

  @Test
  public void request_shouldNotSetBodyWhenNoneIsProvided() throws IOException {
    // Preparation
    WebViewRequest request = mock(WebViewRequest.class);
    when(request.getUrl()).thenReturn("1");
    when(request.getBody()).thenReturn(null);
    when(request.getMethod()).thenReturn(WebViewLoadMethod.POST);
    when(request.getHeaders()).thenReturn(Collections.emptyMap());
    HttpURLConnection mockConnection = mock(HttpURLConnection.class);
    when(mockUrl.openConnection()).thenReturn(mockConnection);

    // Execute
    httpRequestManager.request(request);

    // Validation
    verify(mockConnection, never()).setFixedLengthStreamingMode(anyInt());
    verify(mockConnection, never()).setDoOutput(anyBoolean());
    verify(mockBufferedOutputStream, never()).write(any(), anyInt(), anyInt());
    verify(mockBufferedOutputStream, never()).flush();
  }

  @Test
  public void requestAsync_shouldScheduleRequest() throws IOException {
    // Preparation
    WebViewRequest request = mock(WebViewRequest.class);
    when(request.getUrl()).thenReturn("1");
    when(request.getBody()).thenReturn(null);
    when(request.getMethod()).thenReturn(WebViewLoadMethod.POST);
    when(request.getHeaders()).thenReturn(Collections.emptyMap());
    HttpRequestCallback mockCallback = mock(HttpRequestCallback.class);

    // Execute
    httpRequestManager.requestAsync(request, mockCallback);

    // Validation
    verify(mockExecutor, times(1)).execute(any());
  }

  @Test
  public void requestAsync_shouldCallOnCompleteCallbackOnSuccess() throws IOException {
    // Preparation
    WebViewRequest request = mock(WebViewRequest.class);
    when(request.getUrl()).thenReturn("1");
    when(request.getBody()).thenReturn(null);
    when(request.getMethod()).thenReturn(WebViewLoadMethod.POST);
    when(request.getHeaders()).thenReturn(Collections.emptyMap());
    HttpRequestCallback mockCallback = mock(HttpRequestCallback.class);
    doAnswer(
            (Answer<Object>)
                invocationOnMock -> {
                  Runnable runnable = invocationOnMock.getArgument(0, Runnable.class);
                  runnable.run();
                  return null;
                })
        .when(mockExecutor)
        .execute(any());
    doAnswer(
            (Answer)
                invocationOnMock -> {
                  Runnable runnable = invocationOnMock.getArgument(0, Runnable.class);
                  runnable.run();
                  return null;
                })
        .when(mockHandler)
        .post(any());
    doReturn("RESPONSE").when(httpRequestManager).request(any());

    // Execute
    httpRequestManager.requestAsync(request, mockCallback);

    // Validation
    verify(mockHandler, times(1)).post(any());
    verify(mockCallback, never()).onError(any());
    verify(mockCallback, times(1)).onComplete("RESPONSE");
  }

  @Test
  public void requestAsync_shouldCallOnErrorCallbackOnIOException() throws IOException {
    // Preparation
    WebViewRequest request = mock(WebViewRequest.class);
    when(request.getUrl()).thenReturn("1");
    when(request.getBody()).thenReturn(null);
    when(request.getMethod()).thenReturn(WebViewLoadMethod.POST);
    when(request.getHeaders()).thenReturn(Collections.emptyMap());
    HttpRequestCallback mockCallback = mock(HttpRequestCallback.class);
    doAnswer(
            (Answer<Object>)
                invocationOnMock -> {
                  Runnable runnable = invocationOnMock.getArgument(0, Runnable.class);
                  runnable.run();
                  return null;
                })
        .when(mockExecutor)
        .execute(any());
    doAnswer(
            (Answer)
                invocationOnMock -> {
                  Runnable runnable = invocationOnMock.getArgument(0, Runnable.class);
                  runnable.run();
                  return null;
                })
        .when(mockHandler)
        .post(any());
    IOException exception = new IOException();
    doThrow(exception).when(httpRequestManager).request(any());

    // Execute
    httpRequestManager.requestAsync(request, mockCallback);

    // Validation
    verify(mockHandler, times(1)).post(any());
    verify(mockCallback, never()).onComplete(any());
    verify(mockCallback, times(1)).onError(exception);
  }
}
