import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'utils/router.dart';
import 'providers/user_provider.dart';
import 'providers/report_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/module_provider.dart';
import 'services/voice_assistant_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HelloCareApp());
}

class HelloCareApp extends StatelessWidget {
  const HelloCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => VoiceAssistantService()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final router = createRouter(userProvider);

          return MaterialApp.router(
            title: 'HelloCare',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
