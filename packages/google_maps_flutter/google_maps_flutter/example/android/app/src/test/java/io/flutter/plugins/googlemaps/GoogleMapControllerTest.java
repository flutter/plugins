package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class GoogleMapControllerTest {

  private Context context;
  private Application application;
  private GoogleMapController googleMapController;

  @Mock BinaryMessenger mockMessenger;
  @Mock Activity mockActivity;
  @Mock GoogleMap mockGoogleMap;

  @Before
  public void before() {
    MockitoAnnotations.initMocks(this);
    context = ApplicationProvider.getApplicationContext();
    application = ApplicationProvider.getApplicationContext();
    googleMapController =
        new GoogleMapController(
            0, context, new AtomicInteger(1), mockMessenger, application, null, null, 0, null);
    googleMapController.init();
  }

  @Test
  public void CloseApplicationAndDisposeDontCrash() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);
    googleMapController.onActivityDestroyed(mockActivity);
    googleMapController.dispose();
    assertNull(googleMapController.getView());
  }
}
