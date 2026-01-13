import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// Asegúrate de importar tus widgets correctamente
import 'package:quickflix/features/widgets/home/category_menu.dart';
import 'package:quickflix/features/widgets/home/top_bar.dart';
import 'package:quickflix/features/widgets/home/video_info_card.dart';
import 'package:quickflix/features/widgets/shared/custom_gradient.dart';
import 'package:quickflix/shared/cubits/titles/titles_cubit.dart';
import 'package:quickflix/shared/entities/video_title.dart';

class MoviesSlideshow extends StatefulWidget {
  final List<VideoTitle> movies;

  const MoviesSlideshow({super.key, required this.movies});

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {
  final SwiperController _swiperController = SwiperController();

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
    final videosCubit = context.watch<MoviesCubit>();

    final currentCategory = videosCubit.state.selectedCategory;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: availableHeight * 0.90,
          // 2. Usamos un STACK para superponer capas
          child: Stack(
            children: [
              // CAPA 1 (Fondo): El Carrusel (Swiper)
              Swiper(
                controller: _swiperController,
                viewportFraction: 1.0,
                scale: 1.0,
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
                  // Index changed callback
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
                      selectedCategory: currentCategory,
                      onCategorySelected: (category) {
                        videosCubit.changeCategory(category);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 3. El Slide ahora es "tonto", solo muestra la imagen
class _Slide extends StatelessWidget {
  final VideoTitle movie;

  const _Slide({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo - usa todo el espacio disponible
        SizedBox.expand(
          child: movie.imageUrl.isNotEmpty
              ? Image.network(
                  movie.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    return FadeIn(child: child);
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
        const CustomGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.4],
          colors: [Color(0xFF121212), Colors.transparent],
        ),

        const CustomGradient(
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
