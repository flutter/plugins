package io.flutter.plugins.videoplayer;

import io.flutter.Log;
import java.io.ByteArrayInputStream;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;

class SSLBuilder {
  private static final String TAG = "VideoPlayerPlugin";
  private KeyStore keyStore = null;

  public SSLSocketFactory socketFactoryIfReq() {
    if (keyStore == null) return null;

    try {
      TrustManagerFactory tmf =
          TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
      tmf.init(keyStore);
      SSLContext sslContext = SSLContext.getInstance("TLS");
      sslContext.init(null, tmf.getTrustManagers(), null);
      return sslContext.getSocketFactory();
    } catch (Exception e) {
      Log.w(TAG, "Error adding certificates to SSL Context", e);
      return null;
    }
  }

  public void addCertificate(byte[] bytes) {
    try {
      Certificate certificate =
          CertificateFactory.getInstance("X.509")
              .generateCertificate(new ByteArrayInputStream(bytes));

      KeyStore temp = keyStore;
      if (temp == null) {
        temp = KeyStore.getInstance(KeyStore.getDefaultType());
        temp.load(null, null);
      }

      temp.setCertificateEntry("server" + temp.size(), certificate);
      keyStore = temp;
    } catch (Exception e) {
      Log.w(TAG, "Error adding certificate to java keystore", e);
    }
  }
}
