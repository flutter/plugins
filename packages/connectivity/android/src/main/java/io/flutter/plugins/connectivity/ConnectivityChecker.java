package io.flutter.plugins.connectivity;

import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.os.Build;

/**
 * Responsible for checking connectivity information.
 */
public class ConnectivityChecker {
    private ConnectivityManager manager;

    /**
     * Constructs a ConnectivityChecker
     *
     * @param manager used o check connectivity information.
     */
    ConnectivityChecker(ConnectivityManager manager) {
        this.manager = manager;
    }

    /**
     * Get the network type.
     *
     * @return a String that is one of the following values: "none", "wifi", "mobile".
     */
    String checkNetworkType() {
        return getNetworkType();
    }

    private String getNetworkType() {
        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Network network = manager.getActiveNetwork();
            NetworkCapabilities capabilities = manager.getNetworkCapabilities(network);
            if (capabilities == null) {
                return "none";
            }
            if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                    || capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                return "wifi";
            }
            if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                return "mobile";
            }
        }

        return getNetworkTypeLegacy();
    }

    @SuppressWarnings("deprecation")
    private  String getNetworkTypeLegacy() {
        // handle type for Android versions less than Android 9
        NetworkInfo info = manager.getActiveNetworkInfo();
        if (info == null || !info.isConnected()) {
            return "none";
        }
        int type = info.getType();
        switch (type) {
            case ConnectivityManager.TYPE_ETHERNET:
            case ConnectivityManager.TYPE_WIFI:
            case ConnectivityManager.TYPE_WIMAX:
                return "wifi";
            case ConnectivityManager.TYPE_MOBILE:
            case ConnectivityManager.TYPE_MOBILE_DUN:
            case ConnectivityManager.TYPE_MOBILE_HIPRI:
                return "mobile";
            default:
                return "none";
        }
    }
}
