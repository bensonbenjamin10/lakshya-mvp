import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lakshya_mvp/config/supabase_config.dart';
import 'package:lakshya_mvp/core/repositories/lead_repository.dart';
import 'package:lakshya_mvp/core/repositories/course_repository.dart';
import 'package:lakshya_mvp/services/auth_service.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/providers/theme_provider.dart';
import 'package:lakshya_mvp/providers/favorites_provider.dart';
import 'package:lakshya_mvp/routes/app_router.dart';
import 'package:lakshya_mvp/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(const LakshyaApp());
}

class LakshyaApp extends StatelessWidget {
  const LakshyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection Setup following SOLID principles
    final supabaseClient = Supabase.instance.client;
    
    return MultiProvider(
      providers: [
        // Data Sources
        Provider<SupabaseClient>.value(value: supabaseClient),
        
        // Repositories (depend on data source)
        Provider<CourseRepository>(
          create: (ctx) => CourseRepository(ctx.read<SupabaseClient>()),
        ),
        Provider<LeadRepository>(
          create: (ctx) => LeadRepository(ctx.read<SupabaseClient>()),
        ),
        
        // Services (depend on Supabase client)
        Provider<AuthService>(
          create: (ctx) => AuthService(ctx.read<SupabaseClient>()),
        ),
        
        // Providers (depend on services/repositories)
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<AuthService>()),
        ),
        ChangeNotifierProvider<CourseProvider>(
          create: (ctx) => CourseProvider(ctx.read<CourseRepository>()),
        ),
        ChangeNotifierProvider<LeadProvider>(
          create: (ctx) => LeadProvider(ctx.read<LeadRepository>()),
        ),
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

