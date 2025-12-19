//import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
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
}
