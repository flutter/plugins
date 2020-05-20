package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.util.Log;

import com.google.android.gms.maps.GoogleMap;

import androidx.annotation.Nullable;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.googlemaps.GoogleMapController;

import java.lang.reflect.Method;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;


@RunWith(RobolectricTestRunner.class)
public class GoogleMapControllerTest {

    private Context context;
    private Application application;
    private GoogleMapController googleMapController;

    @Mock
    BinaryMessenger mockMessenger;
    @Mock
    Activity mockActivity;
    @Mock
    GoogleMap mockGoogleMap;

    @Before
    public void before() {
        MockitoAnnotations.initMocks(this);
        context = ApplicationProvider.getApplicationContext();
        application = ApplicationProvider.getApplicationContext();
        googleMapController = new GoogleMapController(0, context, new AtomicInteger(1), mockMessenger, application, null, null, 0, null);
        googleMapController.init();
    }

    @Test
    public void CloseApplicationAndDisposeDontCrash() throws InterruptedException  {
        googleMapController.onMapReady(mockGoogleMap);
        assertTrue(googleMapController != null);
        googleMapController.onActivityDestroyed(mockActivity);
        googleMapController.dispose();
        assertNull(googleMapController.getView());
    }
}