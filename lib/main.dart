import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lakshya_mvp/config/supabase_config.dart';
import 'package:lakshya_mvp/firebase_options.dart';
import 'package:go_router/go_router.dart' show GoRouter;
import 'package:lakshya_mvp/core/repositories/lead_repository.dart';
import 'package:lakshya_mvp/core/repositories/course_repository.dart';
import 'package:lakshya_mvp/core/repositories/video_promo_repository.dart';
import 'package:lakshya_mvp/core/repositories/lead_activity_repository.dart';
import 'package:lakshya_mvp/core/repositories/enrollment_repository.dart';
import 'package:lakshya_mvp/core/repositories/student_progress_repository.dart';
import 'package:lakshya_mvp/core/repositories/course_module_repository.dart';
import 'package:lakshya_mvp/services/auth_service.dart';
import 'package:lakshya_mvp/services/storage_service.dart';
import 'package:lakshya_mvp/services/analytics_service.dart';
import 'package:lakshya_mvp/services/payment/payment_service.dart';
import 'package:lakshya_mvp/providers/lead_provider.dart';
import 'package:lakshya_mvp/providers/course_provider.dart';
import 'package:lakshya_mvp/providers/video_promo_provider.dart';
import 'package:lakshya_mvp/providers/lead_activity_provider.dart';
import 'package:lakshya_mvp/providers/auth_provider.dart';
import 'package:lakshya_mvp/providers/theme_provider.dart';
import 'package:lakshya_mvp/providers/favorites_provider.dart';
import 'package:lakshya_mvp/providers/enrollment_provider.dart';
import 'package:lakshya_mvp/providers/student_provider.dart';
import 'package:lakshya_mvp/routes/app_router.dart';
import 'package:lakshya_mvp/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure URL strategy for web (allows /login, /admin, etc. to work)
  if (kIsWeb) {
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }
  
  // Run app immediately to avoid frame blocking, then initialize services
  runApp(const LakshyaApp());
}

/// Initialize Firebase and Analytics asynchronously
/// Called from splash screen to avoid blocking main thread
Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await AnalyticsService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Continuing without Firebase Analytics...');
  }
}

/// Initialize Supabase asynchronously
/// Called from splash screen to avoid blocking main thread
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

/// Global flag to track initialization state
bool _servicesInitialized = false;

/// Check if services are initialized
bool get servicesInitialized => _servicesInitialized;

/// Mark services as initialized (called from splash screen)
void markServicesInitialized() => _servicesInitialized = true;

class LakshyaApp extends StatefulWidget {
  const LakshyaApp({super.key});

  @override
  State<LakshyaApp> createState() => _LakshyaAppState();
}

class _LakshyaAppState extends State<LakshyaApp> {
  @override
  Widget build(BuildContext context) {
    // Show splash screen while services initialize
    if (!_servicesInitialized) {
      return MaterialApp(
        title: 'Lakshya Institute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: _InitializingSplash(onInitialized: () {
          setState(() {});
        }),
      );
    }

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
        Provider<LeadActivityRepository>(
          create: (ctx) => LeadActivityRepository(ctx.read<SupabaseClient>()),
        ),
        Provider<EnrollmentRepository>(
          create: (ctx) => EnrollmentRepository(ctx.read<SupabaseClient>()),
        ),
        Provider<StudentProgressRepository>(
          create: (ctx) => StudentProgressRepository(ctx.read<SupabaseClient>()),
        ),
        Provider<CourseModuleRepository>(
          create: (ctx) => CourseModuleRepository(ctx.read<SupabaseClient>()),
        ),
        
        // Services (depend on Supabase client)
        Provider<AuthService>(
          create: (ctx) => AuthService(ctx.read<SupabaseClient>()),
        ),
        Provider<StorageService>(
          create: (ctx) => StorageService(ctx.read<SupabaseClient>()),
        ),
        Provider<PaymentService>(
          create: (_) => PaymentService(),
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
        ChangeNotifierProvider<LeadActivityProvider>(
          create: (ctx) => LeadActivityProvider(ctx.read<LeadActivityRepository>()),
        ),
        ChangeNotifierProvider<EnrollmentProvider>(
          create: (ctx) => EnrollmentProvider(
            ctx.read<EnrollmentRepository>(),
            ctx.read<SupabaseClient>(),
          ),
        ),
        ChangeNotifierProvider<StudentProvider>(
          create: (ctx) => StudentProvider(
            ctx.read<EnrollmentRepository>(),
            ctx.read<StudentProgressRepository>(),
            ctx.read<CourseModuleRepository>(),
            ctx.read<SupabaseClient>(),
          ),
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

/// Initial splash screen shown while Firebase/Supabase initialize
/// Uses the same beautiful design as the original splash screen
class _InitializingSplash extends StatefulWidget {
  final VoidCallback onInitialized;
  
  const _InitializingSplash({required this.onInitialized});

  @override
  State<_InitializingSplash> createState() => _InitializingSplashState();
}

class _InitializingSplashState extends State<_InitializingSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final startTime = DateTime.now();
    
    // Initialize Firebase and Supabase in parallel for faster startup
    await Future.wait([
      initializeFirebase(),
      initializeSupabase(),
    ]);

    if (!mounted) return;

    // Mark as initialized
    markServicesInitialized();
    
    // Ensure minimum 3 seconds total splash time
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remainingTime = 3000 - elapsed;
    if (remainingTime > 0) {
      await Future.delayed(Duration(milliseconds: remainingTime));
    }
    
    if (mounted) {
      widget.onInitialized();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Beautiful splash matching the original design
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Simple white to light blue gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF0F5FA), // Very light blue
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Top section with golden accent
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.0,
                            colors: [
                              const Color(0xFFF5DF4D).withValues(alpha: 0.25),
                              const Color(0xFFF5DF4D).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // CENTER: Logo + Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo - uses actual brand image
                        Image.asset(
                          'assets/images/lakshya_logo.png',
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback text logo
                            return Text(
                              'Lakshya',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F4C81),
                                  ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          'Indian Institute of Commerce',
                          style: TextStyle(
                            color: const Color(0xFF0F4C81).withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Bottom section with progress and tagline
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Progress indicator
                        SizedBox(
                          width: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: const LinearProgressIndicator(
                              backgroundColor: Color(0x260F4C81),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0F4C81),
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Tagline badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F4C81).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Color(0xFFF5DF4D),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Excellence in Commerce Education',
                                style: TextStyle(
                                  color: Color(0xFF0F4C81),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

