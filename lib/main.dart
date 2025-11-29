import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lakshya_mvp/config/supabase_config.dart';
import 'package:go_router/go_router.dart' show GoRouter;
import 'package:lakshya_mvp/core/repositories/lead_repository.dart';
import 'package:lakshya_mvp/core/repositories/course_repository.dart';
import 'package:lakshya_mvp/core/repositories/video_promo_repository.dart';
import 'package:lakshya_mvp/services/auth_service.dart';
import 'package:lakshya_mvp/services/storage_service.dart';
import 'package:lakshya_mvp/services/analytics_service.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/video_promo_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/providers/theme_provider.dart';
import 'package:lakshya_mvp/providers/favorites_provider.dart';
import 'package:lakshya_mvp/routes/app_router.dart';
import 'package:lakshya_mvp/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure URL strategy for web (allows /login, /admin, etc. to work)
  if (kIsWeb) {
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }
  
  // Initialize Firebase (must be before Supabase)
  // For web, Firebase will use default app if configured via Firebase Console
  // For mobile, platform-specific configuration files are needed
  try {
    await Firebase.initializeApp();
    await AnalyticsService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Continuing without Firebase Analytics...');
    // Continue without Firebase if initialization fails (e.g., not configured yet)
  }
  
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
        Provider<VideoPromoRepository>(
          create: (ctx) => VideoPromoRepository(ctx.read<SupabaseClient>()),
        ),
        
        // Services (depend on Supabase client)
        Provider<AuthService>(
          create: (ctx) => AuthService(ctx.read<SupabaseClient>()),
        ),
        Provider<StorageService>(
          create: (ctx) => StorageService(ctx.read<SupabaseClient>()),
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
        ChangeNotifierProvider<VideoPromoProvider>(
          create: (ctx) => VideoPromoProvider(ctx.read<VideoPromoRepository>()),
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

