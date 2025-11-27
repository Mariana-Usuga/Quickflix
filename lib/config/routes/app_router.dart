import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mux_videos_app/presentation/screens/home/home_screen.dart';
import 'package:mux_videos_app/presentation/screens/discover/discover_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter
class AppRouter {
  static const String home = '/';
  static const String discover = '/discover';
  
  /// Router principal de la aplicación
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
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
      // Aquí puedes agregar más rutas en el futuro
      // Ejemplo:
      // GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, state) => const ProfileScreen(),
      // ),
    ],
    // Manejo de errores de rutas
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: Ruta no encontrada - ${state.uri}'),
      ),
    ),
  );
}

