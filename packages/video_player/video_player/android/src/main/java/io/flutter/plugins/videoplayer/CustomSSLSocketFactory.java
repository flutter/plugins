// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import java.io.IOException;
import java.net.InetAddress;
import android.os.Build;
import java.net.Socket;
import java.net.UnknownHostException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

public class CustomSSLSocketFactory extends SSLSocketFactory {
  private SSLSocketFactory sslSocketFactory;

  public CustomSSLSocketFactory() throws KeyManagementException, NoSuchAlgorithmException {
    SSLContext context = SSLContext.getInstance("TLS");
    context.init(null, null, null);
    sslSocketFactory = context.getSocketFactory();
    if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
      sslSocketFactory = new TLSSocketFactory(context.getSocketFactory());
    }
    connection.setSSLSocketFactory(sslSocketFactory);
  }

  @Override
  public String[] getDefaultCipherSuites() {
    return sslSocketFactory.getDefaultCipherSuites();
  }

  @Override
  public String[] getSupportedCipherSuites() {
    return sslSocketFactory.getSupportedCipherSuites();
  }

  @Override
  public Socket createSocket() throws IOException {
    return enableProtocols(sslSocketFactory.createSocket());
  }

  @Override
  public Socket createSocket(Socket s, String host, int port, boolean autoClose)
      throws IOException {
    return enableProtocols(sslSocketFactory.createSocket(s, host, port, autoClose));
  }

  @Override
  public Socket createSocket(String host, int port) throws IOException {
    return enableProtocols(sslSocketFactory.createSocket(host, port));
  }

  @Override
  public Socket createSocket(String host, int port, InetAddress localHost, int localPort)
      throws IOException {
    return enableProtocols(sslSocketFactory.createSocket(host, port, localHost, localPort));
  }

  @Override
  public Socket createSocket(InetAddress host, int port) throws IOException {
    return enableProtocols(sslSocketFactory.createSocket(host, port));
  }

  @Override
  public Socket createSocket(InetAddress address, int port, InetAddress localAddress, int localPort)
      throws IOException {
    return enableProtocols(sslSocketFactory.createSocket(address, port, localAddress, localPort));
  }

  private Socket enableProtocols(Socket socket) {
    if (socket instanceof SSLSocket) {
      ((SSLSocket) socket).setEnabledProtocols(new String[] {"TLSv1.1", "TLSv1.2"});
    }
    return socket;
  }
}

public static class TLSSocketFactory extends SSLSocketFactory {

    private SSLSocketFactory internalSSLSocketFactory;

    public TLSSocketFactory(SSLSocketFactory delegate) throws KeyManagementException, NoSuchAlgorithmException {
        internalSSLSocketFactory = delegate;
    }

    @Override
    public String[] getDefaultCipherSuites() {
        return internalSSLSocketFactory.getDefaultCipherSuites();
    }

    @Override
    public String[] getSupportedCipherSuites() {
        return internalSSLSocketFactory.getSupportedCipherSuites();
    }

    @Override
    public Socket createSocket(Socket s, String host, int port, boolean autoClose) throws IOException {
        return enableTLSOnSocket(internalSSLSocketFactory.createSocket(s, host, port, autoClose));
    }

    @Override
    public Socket createSocket(String host, int port) throws IOException, UnknownHostException {
        return enableTLSOnSocket(internalSSLSocketFactory.createSocket(host, port));
    }

    @Override
    public Socket createSocket(String host, int port, InetAddress localHost, int localPort) throws IOException, UnknownHostException {
        return enableTLSOnSocket(internalSSLSocketFactory.createSocket(host, port, localHost, localPort));
    }

    @Override
    public Socket createSocket(InetAddress host, int port) throws IOException {
        return enableTLSOnSocket(internalSSLSocketFactory.createSocket(host, port));
    }

    @Override
    public Socket createSocket(InetAddress address, int port, InetAddress localAddress, int localPort) throws IOException {
        return enableTLSOnSocket(internalSSLSocketFactory.createSocket(address, port, localAddress, localPort));
    }

    /*
     * Utility methods
     */

    private static Socket enableTLSOnSocket(Socket socket) {
        if (socket != null && (socket instanceof SSLSocket)
                && isTLSServerEnabled((SSLSocket) socket)) { // skip the fix if server doesn't provide there TLS version
            ((SSLSocket) socket).setEnabledProtocols(new String[]{"TLS_v1_1", "TLS_v1_2"});
        }
        return socket;
    }

    private static boolean isTLSServerEnabled(SSLSocket sslSocket) {
        System.out.println("__prova__ :: " + sslSocket.getSupportedProtocols().toString());
        for (String protocol : sslSocket.getSupportedProtocols()) {
            if (protocol.equals("TLS_v1_1") || protocol.equals("TLS_v1_2")) {
                return true;
            }
        }
        return false;
    }
}
