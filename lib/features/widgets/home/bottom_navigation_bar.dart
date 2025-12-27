import 'dart:ui'; // Necesario para ImageFilter
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/features/search/delegates/search_movie_delegate.dart';
import 'package:quickflix/models/movie.dart';
import 'package:quickflix/services/local_video_services.dart';
// Asegúrate de importar tus archivos necesarios:
// import 'package:quickflix/features/search/search_movie_delegate.dart';
// import 'package:quickflix/services/local_video_services.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home/0');
        break;
      case 1:
        final localVideoServices =
            LocalVideoServices(); // Asegúrate de tener esta instancia o inyectarla
        showSearch<Movie?>(
            query: '',
            context: context,
            delegate: SearchMovieDelegate(
              searchMovies: localVideoServices.searchMoviesByQuery,
              initialMovies: const [],
            )).then((movie) {
          if (movie == null) return;
          context.push('/home/0/movie/${movie.id}');
        });
        break;
      case 2:
        context.go('/home/2');
        break;
      case 3:
        context.go('/home/3'); // Perfil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Altura de la barra
    const double barHeight = 60; // Altura reducida

    return SizedBox(
      height: barHeight,
      // Usamos Stack para simular el FrostedGlassBox pero adaptado a la barra
      child: Stack(
        children: [
          // CAPA 1: El efecto borroso (Blur)
          // Esto desenfoca lo que pasa por DETRÁS de la barra (las películas)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 10.0, sigmaY: 10.0), // Nivel de borroso
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // CAPA 2: El tinte oscuro y el borde (La estética del vidrio)
          Container(
            decoration: BoxDecoration(
              // Gradiente de negro transparente a negro un poco más sólido
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6), // Arriba más transparente
                  Colors.black.withOpacity(0.9), // Abajo más oscuro
                ],
              ),
              // Borde sutil blanco arriba (para definir donde empieza la barra)
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
            ),
          ),

          // CAPA 3: Los Iconos
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBarIcon(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_filled, // Casita rellena
                  onTap: () => onItemTapped(context, 0),
                ),
                _NavBarIcon(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.search, // Lupa
                  onTap: () => onItemTapped(context, 1),
                ),
                _NavBarIcon(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.bookmark_border, // Guardados
                  onTap: () => onItemTapped(context, 2),
                ),
                _NavBarIcon(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.person_outline, // Perfil
                  onTap: () => onItemTapped(context, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pequeño para cada icono (para no repetir código)
class _NavBarIcon extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    // Si está seleccionado es ROJO, si no es BLANCO GRISÁCEO (como tu screenshot)
    final color = isSelected ? const Color(0xFFE50914) : Colors.white70;

    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickflix/features/search/delegates/search_movie_delegate.dart';
import 'package:quickflix/services/local_video_services.dart';
import 'package:quickflix/models/movie.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigation({super.key, required this.currentIndex});

  void onItemTapped(BuildContext context, int index) {
    // context.go('');
    switch (index) {
      case 0:
        context.go('/home/0');
        break;

      case 1:
        //delagate:se encarga de trabajar la busqueda
        final localVideoServices = LocalVideoServices();
        showSearch<Movie?>(
                query: '',
                context: context,
                delegate: SearchMovieDelegate(
                  searchMovies: localVideoServices.searchMoviesByQuery,
                  initialMovies: const [],
                )) // dar la referencia
            .then((movie) {
          if (movie == null) return;
          context.push('/home/0/movie/${movie.id}');
        });
        //context.go('/home/1');
        break;

      case 2:
        context.go('/home/2');
        break;
      case 3:
        context.go('/home/2');
        break;
    }
  }

  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) => onItemTapped(context, value),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumbs_up_down_outlined),
            label: 'Populares',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
        ]);
  }
}*/

/*import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.search, 'Search', 1),
          _buildNavItem(Icons.bookmark_border, 'Saved', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}*/
