import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wrapper_example/src/example_library.pigeon.dart';
import 'package:wrapper_example/src/instance_manager.dart';
import 'package:wrapper_example/src/my_class.dart';
import 'package:wrapper_example/wrapper_example.dart';

import 'my_class_test.mocks.dart';
import 'test_example_library.pigeon.dart';

// Create a mock of the generated
@GenerateMocks(<Type>[TestMyClassHostApi])
void main() {
  // Ensures binary messenger is usable.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyClass', () {
    // Ensure the test host api is removed after each test run.
    tearDown(() => TestMyClassHostApi.setup(null));

    test('hostApiCreate', () {
      // Sets a mock platform host api implementation. This serves as the
      // Java/Objective-C host api implementation.
      final MockTestMyClassHostApi mockApi = MockTestMyClassHostApi();
      TestMyClassHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      // Add a MyOtherClass instance to InstanceManager since it is a required
      // parameter to the MyClass constructor.
      final MyOtherClass myOtherClass = MyOtherClass.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        myOtherClass,
        2,
        onCopy: (_) => MyOtherClass.detached(),
      );

      // Instantiate a MyClass instance with the instance manager.
      final MyClass myClass = MyClass(
        'myString',
        myOtherClass,
        instanceManager: instanceManager,
      );

      // Verify mock host api received the correct values.
      verify(mockApi.create(
        instanceManager.getIdentifier(myClass),
        'myString',
        2,
      ));
    });

    test('myStaticMethod', () {
      // Sets a mock platform host api implementation. This serves as the
      // Java/Objective-C host api implementation.
      final MockTestMyClassHostApi mockApi = MockTestMyClassHostApi();
      TestMyClassHostApi.setup(mockApi);

      // Call my static method.
      MyClass.myStaticMethod();

      // Verify mock host api was called.
      verify(mockApi.myStaticMethod());
    });

    test('myMethod', () {
      // Sets a mock platform host api implementation. This serves as the
      // Java/Objective-C host api implementation.
      final MockTestMyClassHostApi mockApi = MockTestMyClassHostApi();
      TestMyClassHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      // Create a MyClass instance and add to the instanceManager with
      // identifier = 1.
      final MyClass myClass = MyClass.detached(
        'myString',
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        myClass,
        0,
        onCopy: (_) => MyClass.detached('myString'),
      );

      // Add a MyOtherClass instance to InstanceManager since it is a required
      // parameter to the MyClass constructor.
      final MyOtherClass myOtherClass = MyOtherClass.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        myOtherClass,
        1,
        onCopy: (_) => MyOtherClass.detached(),
      );

      // Call my method.
      myClass.myMethod('myMethodString', myOtherClass);

      // Verify mock host api received the correct values.
      verify(mockApi.myMethod(0, 'myMethodString', 1));
    });

    test('flutterApiCreate', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final MyClassFlutterApi flutterApi = MyClassFlutterApiImpl(
        instanceManager: instanceManager,
      );

      flutterApi.create(0, 'myString');

      expect(instanceManager.getInstanceWithWeakReference(0), isA<MyClass>());
    });

    test('myCallbackMethod', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      late final MyClass? callbackValue;
      final MyClass myClass = MyClass.detached(
        'myString',
        myCallbackMethod: (MyClass instance) => callbackValue = instance,
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        myClass,
        0,
        onCopy: (_) => MyClass.detached('myString'),
      );

      final MyClassFlutterApi flutterApi = MyClassFlutterApiImpl(
        instanceManager: instanceManager,
      );
      flutterApi.myCallbackMethod(0);

      expect(callbackValue, myClass);
    });
  });
}
