import 'package:go_router/go_router.dart';
import 'package:quickflix/features/discover/discover_screen.dart';
import 'package:quickflix/features/home/home_screen.dart';
import 'package:quickflix/features/widgets/movie_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
/// final appRouter = GoRouter(initialLocation: '/home/0', routes: [
final appRouter = GoRouter(initialLocation: '/home/0', routes: [
  GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        var pageIndex = int.parse(state.pathParameters['page'] ?? '0');
        if (pageIndex > 3 || pageIndex < 0) {
          return const HomeScreen(pageIndex: (0));
        }
        return HomeScreen(pageIndex: (pageIndex));
      },
      routes: [
        GoRoute(
          path: 'movie/:id',
          //name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no';
            return MovieScreen(movieId: movieId);
          },
        ),
        GoRoute(
          path: 'discover',
          //name: MovieScreen.name,
          builder: (context, state) {
            return DiscoverScreen();
          },
        )
      ]),
  GoRoute(path: '/', redirect: (_, __) => '/home/0')
]);

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
