import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/routes/app_router.dart';
import 'package:lakshya_mvp/theme/app_theme.dart';

void main() {
  runApp(const LakshyaApp());
}

class LakshyaApp extends StatelessWidget {
  const LakshyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
      ],
      child: MaterialApp.router(
        title: 'Lakshya Institute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

