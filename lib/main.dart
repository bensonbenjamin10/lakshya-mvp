import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/theme_provider.dart';
import 'package:lakshya_mvp/providers/favorites_provider.dart';
import 'package:lakshya_mvp/routes/app_router.dart';
import 'package:lakshya_mvp/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Lakshya Institute',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              extensions: [
                StatusColors.light,
                BrandAccents.light,
                CourseColors.light,
              ],
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              extensions: [
                StatusColors.dark,
                BrandAccents.dark,
                CourseColors.dark,
              ],
            ),
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

