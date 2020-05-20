package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertTrue;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.googlemaps.GoogleMapController;

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

    @Before
    public void before() {
        context = ApplicationProvider.getApplicationContext();
        application = ApplicationProvider.getApplicationContext();
        googleMapController = new GoogleMapController(0, context, new AtomicInteger(0), mockMessenger, application, null, null, 0, null);
    }

    @Test
    public void CloseApplicationAndDisposeDontCrash() {
        assertTrue(googleMapController != null);
//        assertTrue(googleMapController.getView() != null);
        googleMapController.onActivityDestroyed(mockActivity);
        googleMapController.dispose();
        assertTrue(googleMapController.getView() == null);
    }
}