import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'constants/app_theme.dart';
import 'utils/service_locator.dart'; // Import the locator

// Import ViewModels as we add them (placeholder for now)

void main() {
  // Initialize ServiceLocator and register services (expand as we go)
  final serviceLocator = ServiceLocator();
  // Example: serviceLocator.register<UserService>(UserServiceImpl(...)); // We'll add real ones later

  runApp(
    MultiProvider(
      providers: [
        // Add ViewModel providers here as we implement them, e.g.:
        // ChangeNotifierProvider(create: (_) => OnboardingViewModel(serviceLocator.get<UserService>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOLVL',
      theme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(child: Text('Welcome to YOLVL!')),
      ),
    );
  }
}