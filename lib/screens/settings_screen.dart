import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_sn.dart';
import 'language_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Helper method to get the correct localizations based on user's language choice
  AppLocalizations _getLocalizations(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    if (languageProvider.locale.languageCode == 'sn') {
      return AppLocalizationsSn();
    } else {
      return AppLocalizationsEn();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: 16),
            _buildAccountCard(),

            const SizedBox(height: 30),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 16),
            _buildAppearanceCard(themeProvider),

            const SizedBox(height: 30),

            // Language Section
            _buildSectionHeader('Language'),
            const SizedBox(height: 16),
            _buildLanguageCard(),

            const SizedBox(height: 30),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            const SizedBox(height: 16),
            _buildSettingsCard(),

            const SizedBox(height: 30),

            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 16),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAccountCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!authProvider.isAuthenticated) ...[
                  const Text(
                    'Sign in to sync your data across devices',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  _buildLoginForm(),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.email ?? 'No email',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Data synced to cloud',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _signOut(context),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !authProvider.isLoading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !authProvider.isLoading,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _signIn(context),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _signUp(context),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppearanceCard(ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeProvider.themeMode == ThemeMode.dark ? 'On' : 'Off',
              ),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
                activeColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    final theme = Theme.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = _getLocalizations(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.language, color: theme.colorScheme.primary),
              title: Text(localizations.language),
              subtitle: Text(
                _getCurrentLanguageName(languageProvider.locale.languageCode),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'sn':
        return 'Shona';
      default:
        return 'English';
    }
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Period reminders and predictions'),
            trailing: Switch(
              value: true, // Replace with actual notification setting
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.backup,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your cycle data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement data backup
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Privacy'),
            subtitle: const Text('Data usage and privacy settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement privacy settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('About Cycle Tracker'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              // TODO: Show app info
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.support,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Support'),
            subtitle: const Text('Get help and contact us'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement support
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Rate App'),
            subtitle: const Text('Help us improve'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Implement app rating
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signIn(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      authProvider.clearError();
      final success = await authProvider.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        // Update cycle provider with authenticated user
        await cycleProvider.updateUserAuthentication(authProvider.user?.uid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully signed in!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _emailController.clear();
        _passwordController.clear();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signUp(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      authProvider.clearError();
      final success = await authProvider.createUserWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        // Update cycle provider with authenticated user
        await cycleProvider.updateUserAuthentication(authProvider.user?.uid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        _emailController.clear();
        _passwordController.clear();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);

    await authProvider.signOut();
    await cycleProvider.updateUserAuthentication(null);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed out successfully')));
    }
  }
}
