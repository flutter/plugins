class InstanceManager {
  Map<int, Object> _instanceIdToInstances = <int, Object>{};
  Map<Object, int> _instancesToInstanceId = <Object, int>{};

  static int _nextInstanceId = 0;

  static final InstanceManager instance = InstanceManager();

  int? tryAddInstance(Object instance) {

  }

  int? removeInstance(Object instance) {

  }

  Object? getInstance(int instanceId) {

  }

  int? getInstanceId(Object instance) {

  }
}