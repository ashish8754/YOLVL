import 'package:yolvl/services/user_service.dart'; // Placeholder—import actual services as we add them
// Add more service imports here as we implement them (e.g., leveling_service.dart)

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  void register<T extends Object>(T service) {
    _services[T] = service;
  }

  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service $T not registered');
    }
    return service as T;
  }

  // Future: Add lazy loading or factory registration for more advanced DI
}