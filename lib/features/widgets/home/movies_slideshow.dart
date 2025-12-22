import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:go_router/go_router.dart';
// Asegúrate de importar tus widgets correctamente
import 'package:quickflix/features/widgets/home/category_menu.dart';
import 'package:quickflix/features/widgets/home/top_bar.dart';
import 'package:quickflix/features/widgets/home/video_info_card.dart';
import 'package:quickflix/models/video_post.dart';

class MoviesSlideshow extends StatefulWidget {
  final List<VideoPost> movies;

  const MoviesSlideshow({super.key, required this.movies});

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {
  // 1. Movemos el estado aquí porque el menú ya no está en cada Slide
  String _selectedCategory = 'Popular';
  final SwiperController _swiperController = SwiperController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

    return SizedBox(
      width: double.infinity,
      height: availableHeight * 0.85,
      // 2. Usamos un STACK para superponer capas
      child: Stack(
        children: [
          // CAPA 1 (Fondo): El Carrusel (Swiper)
          Swiper(
            controller: _swiperController,
            viewportFraction: 1.0,
            scale: 0.9,
            //autoplay: true,
            pagination: SwiperPagination(
              builder: SwiperCustomPagination(
                builder: (BuildContext context, SwiperPluginConfig config) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(config.itemCount, (index) {
                      final bool isActive = index == config.activeIndex;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 40.0 : 12.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.movies.length,
            itemBuilder: (context, index) =>
                _Slide(movie: widget.movies[index]),
          ),

          SafeArea(
            child: Column(
              children: [
                const TopBar(),
                const SizedBox(height: 5),
                CategoryMenu(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. El Slide ahora es "tonto", solo muestra la imagen
class _Slide extends StatelessWidget {
  final VideoPost movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo
        SizedBox.expand(
          child: movie.imageUrl.isNotEmpty
              ? Image.network(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    return FadeIn(child: child);
                    /*if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF121212),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );*/
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF121212),
                      child: const Center(
                        child:
                            Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    );
                  },
                )
              : Container(
                  color: const Color(0xFF121212),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
        ),

        // Gradiente inferior (Este sí se mueve con la imagen)
        const _CustomGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.4],
          colors: [Color(0xFF121212), Colors.transparent],
        ),

        const _CustomGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.3],
          colors: [Color.fromARGB(255, 0, 0, 0), Colors.transparent],
        ),

        // VideoInfoCard posicionado en la parte inferior
        Positioned(
          //top: 80,
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoInfoCard(
            video: movie,
            currentIndex: 0,
            totalVideos: 1,
            onPlayPressed: () {
              // Navegar a la pantalla de scroll vertical
              context.push('/discover');
            },
          ),
        ),
        // Aquí iría la info de la película si quieres que se mueva con el slide
      ],
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGradient(
      {this.begin = Alignment.centerLeft,
      this.end = Alignment.centerRight,
      required this.stops,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, stops: stops, colors: colors))),
    );
  }
}
//import 'package:animate_do/animate_do.dart';
/*import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:quickflix/features/widgets/home/category_menu.dart';
import 'package:quickflix/features/widgets/home/top_bar.dart';
import 'package:quickflix/models/video_post.dart';

class MoviesSlideshow extends StatelessWidget {
  final List<VideoPost> movies;

  const MoviesSlideshow({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

    return SizedBox(
      height: availableHeight * 0.85,
      width: double.infinity,
      child: Swiper(
        viewportFraction: 0.8,
        scale: 0.9,
        //autoplay: true,
        pagination: SwiperPagination(
            margin: const EdgeInsets.only(top: 0),
            builder: DotSwiperPaginationBuilder(
                activeColor: colors.primary, color: colors.secondary)),
        itemCount: movies.length,
        itemBuilder: (context, index) => _Slide(movie: movies[index]),
      ),
    );
  }
}

class _Slide extends StatefulWidget {
  final VideoPost movie;

  const _Slide({required this.movie});

  @override
  State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> {
  @override
  Widget build(BuildContext context) {
    String _selectedCategory = 'Popular';
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final availableHeight = screenHeight - safeAreaTop - safeAreaBottom;

        return SizedBox(
          height: availableHeight * 0.85,
          child: Stack(
            children: [
              // Imagen de fondo
              SizedBox.expand(
                child: Image.asset(
                  'assets/background.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Si falla la carga de la imagen, mostrar un color de fondo
                    return Container(
                      color: const Color(0xFF121212),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),

              _CustomGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    0.0,
                    0.3
                  ],
                  colors: [
                    Color(0xFF121212),
                    Colors.transparent,
                  ]),

              // Contenido superpuesto
              SafeArea(
                child: Column(
                  children: [
                    // Barra superior
                    const TopBar(),

                    const SizedBox(height: 5),

                    // Menú de categorías
                    CategoryMenu(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),

                    /*Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: VideoInfoCard(
                            video: heroVideo,
                            currentIndex: 0,
                            totalVideos: 1,
                            onPlayPressed: () {
                              // Navegar a la pantalla de scroll vertical
                              context.push('/discover');
                            },
                          ),
                        ),
                      ),*/

                    //const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomGradient extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double> stops;
  final List<Color> colors;

  const _CustomGradient(
      {this.begin = Alignment.centerLeft, //valores por defecto
      this.end = Alignment.centerRight,
      required this.stops,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: begin, end: end, stops: stops, colors: colors))),
    );
  }
}*/
