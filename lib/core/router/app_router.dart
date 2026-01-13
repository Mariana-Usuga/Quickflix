import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/features/auth/cubit/auth_cubit.dart';
import 'package:quickflix/features/auth/screens/login_screen.dart';
import 'package:quickflix/features/auth/screens/splash_screen.dart';
import 'package:quickflix/features/discover/screens/discover_screen.dart';
import 'package:quickflix/features/home/home_screen.dart';
import 'package:quickflix/features/profile/screeens/privacy_policy_screen.dart';
import 'package:quickflix/features/profile/screeens/terms_of_use_screen.dart';
import 'package:quickflix/features/widgets/movie_screen.dart';
import 'package:quickflix/core/router/auth_listener.dart';

/// Crea el router con el listener de autenticación
GoRouter createAppRouter(AuthCubit authCubit) {
  final authListener = AuthListener(authCubit);

  return GoRouter(
    refreshListenable: authListener,
    initialLocation: '/splash',
    redirect: (context, state) {
      // Obtener el estado de autenticación
      final authState = context.read<AuthCubit>().state;
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToHome = state.matchedLocation.startsWith('/home');

      // Si está cargando (verificando sesión), mostrar splash
      if (authState is AuthLoading) {
        return isGoingToSplash ? null : '/splash';
      }

      // Si está autenticado, redirigir a home si no está ahí
      if (authState is AuthSuccess) {
        if (isGoingToLogin || isGoingToSplash) {
          return '/home/0';
        }
        return null; // Permitir navegación normal
      }

      // Si no está autenticado, redirigir a login si no está ahí
      if (authState is Unauthenticated || authState is AuthInitial) {
        if (isGoingToHome || isGoingToSplash) {
          return '/login';
        }
        return null; // Permitir navegación normal
      }

      // Para otros estados (AuthFailure), permitir navegación normal
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home/:page',
        name: HomeScreen.name,
        builder: (context, state) {
          var pageIndex = int.parse(state.pathParameters['page'] ?? '0');
          if (pageIndex > 4 || pageIndex < 0) {
            return const HomeScreen(pageIndex: 0);
          }
          return HomeScreen(pageIndex: pageIndex);
        },
        routes: [
          GoRoute(
            path: 'movie/:id',
            builder: (context, state) {
              final movieId = state.pathParameters['id'] ?? 'no';
              return MovieScreen(movieId: movieId);
            },
          ),
          GoRoute(
            path: 'discover',
            builder: (context, state) {
              return const DiscoverScreen();
            },
          ),
          GoRoute(
            path: 'terms-of-use',
            builder: (context, state) {
              return const TermsOfUseScreen();
            },
          ),
          GoRoute(
            path: 'privacy-policy',
            builder: (context, state) {
              return const PrivacyPolicyScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
    ],
  );
}

/// Router por defecto (se actualizará en main.dart)
late GoRouter appRouter;

/*class AppRouter {
  static const String login = '/';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String myList = '/myList';
  static const String profile = '/profile';

  /// Router principal de la aplicación
  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: discover,
        name: 'discover',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: myList,
        name: 'myList',
        builder: (context, state) => const MyListScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    // Manejo de errores de rutas
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: Ruta no encontrada - ${state.uri}'),
      ),
    ),
  );
}*/
