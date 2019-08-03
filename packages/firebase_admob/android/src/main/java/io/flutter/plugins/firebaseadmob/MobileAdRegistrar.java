package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.util.SparseArray;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.ads.AdSize;
import io.flutter.plugin.common.MethodChannel;

/* Class that acts as Factory and registry for MobileAds. */
class MobileAdRegistrar {
  private SparseArray<MobileAd> allAds = new SparseArray<>();

  /* Returns a MobileAd if it is registered in this Registrar. */
  @Nullable
  MobileAd getAdForId(Integer id) {
    return allAds.get(id);
  }

  /* Registers a new MobileAd with the given id. */
  void register(int id, MobileAd ad) {
    allAds.put(id, ad);
  }

  /* Returns an already registered Banner with the given id or creates a new Banner. */
  @NonNull
  MobileAd.Banner createBanner(
      Integer id, AdSize adSize, Activity activity, MethodChannel channel) {
    MobileAd ad = getAdForId(id);
    return (ad != null)
        ? (MobileAd.Banner) ad
        : new MobileAd.Banner(this, id, adSize, activity, channel);
  }

  /* Returns an already registered Interstitial with the given id or creates a new Interstitial. */
  @NonNull
  MobileAd.Interstitial createInterstitial(Integer id, Activity activity, MethodChannel channel) {
    MobileAd ad = getAdForId(id);
    return (ad != null)
        ? (MobileAd.Interstitial) ad
        : new MobileAd.Interstitial(this, id, activity, channel);
  }

  /* Unregisters a MobileAd with the given id. */
  void unregister(Integer id) {
    allAds.remove(id);
  }
}
