import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:menstrual_tracker/providers/auth_provider.dart';
import 'package:menstrual_tracker/screens/main/main_screen.dart';
import 'package:menstrual_tracker/screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('🔐 AuthWrapper: Checking authentication state');
        print('📝 User authenticated: ${authProvider.isAuthenticated}');
        print('📝 User: ${authProvider.user?.email}');

        // Show loading spinner while auth state is being determined
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, go to main screen
        if (authProvider.isAuthenticated) {
          print('✅ User is authenticated, showing MainScreen');
          return const MainScreen();
        }

        // If user is not authenticated, show login screen
        print('🔓 User not authenticated, showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
