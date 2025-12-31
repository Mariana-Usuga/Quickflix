import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/features/widgets/home/quick_refills_widget.dart';
import 'package:quickflix/features/widgets/shared/video_buttons.dart';
import 'package:quickflix/features/widgets/video/cubit/video_cubit.dart';
import 'package:quickflix/features/widgets/video/fullscreen_player.dart';
import 'package:quickflix/models/episodes.dart';
import 'package:video_player/video_player.dart';

class VideoScrollableView extends StatefulWidget {
  final List<Episode> videos;

  const VideoScrollableView({super.key, required this.videos});

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  late PageController _pageController;
  bool _isModalVisible = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isModalVisible = false;
    });
  }

  void _onModalVisibilityChanged(bool isVisible) {
    setState(() {
      _isModalVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // Deshabilitar scroll si el modal está visible o si está en el episodio 10
      physics: (_isModalVisible ||
              (_currentIndex < widget.videos.length &&
                  widget.videos[_currentIndex].episodeNumber == 10))
          ? const NeverScrollableScrollPhysics()
          : BouncingScrollPhysics(),
      onPageChanged: _onPageChanged,
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final Episode videoPost = widget.videos[index];

        return _VideoPage(
          videoPost: videoPost,
          onModalVisibilityChanged: _onModalVisibilityChanged,
          onRedirectBack: () {
            if (index > 0) {
              _pageController.animateToPage(
                index - 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
              );
            }
          },
        );
      },
    );
  }
}

class _VideoPage extends StatefulWidget {
  final Episode videoPost;
  final ValueChanged<bool>? onModalVisibilityChanged;
  final VoidCallback? onRedirectBack;

  const _VideoPage({
    required this.videoPost,
    this.onModalVisibilityChanged,
    this.onRedirectBack,
  });

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage>
    with SingleTickerProviderStateMixin {
  bool _showRefillModal = false;
  bool _showQuickRefills = false;
  bool _isExiting = false;
  Timer? _timer;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Inicializar el AnimationController para la animación de slide
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Empieza desde abajo
      end: Offset.zero, // Termina en su posición normal
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Si es el episodio 10, iniciar timer para mostrar el modal después de 2 segundos
    if (widget.videoPost.episodeNumber == 10) {
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          // Pausar el video
          context.read<VideoCubit>().togglePlayPause();
          setState(() {
            _showRefillModal = true;
          });
          widget.onModalVisibilityChanged?.call(true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _onRefillToWatch() {
    // Ocultar el modal de refill y mostrar QuickRefillsWidget
    setState(() {
      _showRefillModal = false;
      _showQuickRefills = true;
    });
    // Iniciar la animación de slide desde abajo
    _slideAnimationController.forward();
    // El modal sigue visible (QuickRefillsWidget), así que mantener el scroll deshabilitado
    widget.onModalVisibilityChanged?.call(true);
  }

  void _onCloseQuickRefills() {
    // Cerrar QuickRefillsWidget con animación
    _slideAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showQuickRefills = false;
        });
        widget.onModalVisibilityChanged?.call(false);
        widget.onRedirectBack?.call();
      }
    });
  }

  void _onCloseModal() async {
    setState(() => _isExiting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _showRefillModal = false;
      });
      widget.onModalVisibilityChanged?.call(false);
      widget.onRedirectBack?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //video player + gradientes
        SizedBox.expand(
            child: FullScreenPlayer(
          videoUrl: widget.videoPost.episodeUrl,
          caption: widget.videoPost.episodeNumber.toString(),
          overlay: BlocBuilder<VideoCubit, VideoState>(
            buildWhen: (previous, current) {
              // Solo reconstruir cuando cambie el controller o el estado de inicialización
              return previous.controller != current.controller ||
                  previous.isInitialized != current.isInitialized;
            },
            builder: (context, videoState) {
              return Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: videoState.controller != null && videoState.isInitialized
                    ? _VideoProgressBar(
                        controller: videoState.controller!,
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        )),

        // Botón de play/pause usando VideoCubit
        /*BlocBuilder<VideoCubit, VideoState>(
          buildWhen: (previous, current) {
            // Solo reconstruir cuando cambie el estado de reproducción
            return previous.controller?.value.isPlaying !=
                current.controller?.value.isPlaying;
          },
          builder: (context, videoState) {
            final isPlaying = videoState.controller?.value.isPlaying ?? false;
            return Center(
              child: GestureDetector(
                onTap: () {
                  context.read<VideoCubit>().togglePlayPause();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            );
          },
        ),*/

        // botones
        Positioned(
          bottom: 40,
          right: 20,
          child: VideoButtons(video: widget.videoPost),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 80, // Menos espacio para dar más ancho a _VideoInfo
          child: _VideoInfo(
            title: 'Flash Marrige ${widget.videoPost.episodeNumber}',
            description:
                'A flash marriage" synopsis typically involves a fast, often unexpected marriage between strangers or acquaintances, common in Chinese web novels and dramas like Flash Marriage: The Big Shots Pampered Wife, where a heroine (like Bella) enters a contract marriage with a powerful CEO (Jesse) for convenience (revenge, family, business), only for genuine romance to blossom amidst corporate rivals and challenges, turning their fake union into real love',
            currentEpisode: widget.videoPost.episodeNumber,
            totalEpisodes: 11,
          ),
        ),

        // Overlay oscuro cuando el modal está visible
        if ((_showRefillModal || _showQuickRefills) &&
            widget.videoPost.episodeNumber == 10)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
            ),
          ),

        // Modal de Refill
        if (_showRefillModal && widget.videoPost.episodeNumber == 10)
          Center(
            child: Stack(
              children: [
                _RefillModal(
                  episode: widget.videoPost,
                  onRefillToWatch: _onRefillToWatch,
                ),
                // Botón X para cerrar en la esquina superior derecha
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 20,
                  child: GestureDetector(
                    onTap: _onCloseModal,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // QuickRefillsWidget con animación de slide desde abajo
        if (_showQuickRefills && widget.videoPost.episodeNumber == 10)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                children: [
                  const QuickRefillsWidget(),
                  // Botón X para cerrar QuickRefillsWidget en la esquina superior derecha
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 20,
                    child: GestureDetector(
                      onTap: _onCloseQuickRefills,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _VideoInfo extends StatefulWidget {
  final String title;
  final String description;
  final int currentEpisode;
  final int totalEpisodes;

  const _VideoInfo({
    required this.title,
    required this.description,
    required this.currentEpisode,
    required this.totalEpisodes,
  });

  @override
  State<_VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<_VideoInfo> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF5F5F5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Descripción con botón More/Less
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.description.isNotEmpty
                    ? widget.description
                    : 'Sin descripción disponible',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),
              if (widget.description.length > 100)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _isExpanded ? 'Less' : 'More...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF5F5F5),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Indicador de episodio (EP.9 / 10) - debajo de la descripción
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EP.${widget.currentEpisode} / ${widget.totalEpisodes}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    //_startTimer();
  }

  @override
  void didUpdateWidget(_VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _cancelTimer();
      //_startTimer();
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  /*void _startTimer() {
    _cancelTimer(); // Asegurarse de cancelar cualquier timer anterior
    if (!mounted) return; // Si el widget no está montado, no iniciar el timer

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        // Si el widget se desmontó, cancelar el timer
        timer.cancel();
        return;
      }
      if (widget.controller.value.isInitialized) {
        setState(() {});
      }
    });
  }*/

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final duration = widget.controller.value.duration;
    final position = widget.controller.value.position;

    if (duration.inMilliseconds == 0) {
      return const SizedBox.shrink();
    }

    final progress = position.inMilliseconds / duration.inMilliseconds;

    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: Stack(
        children: [
          // Fondo de la barra
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          // Barra de progreso
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefillModal extends StatelessWidget {
  final Episode episode;
  final VoidCallback onRefillToWatch;

  const _RefillModal({
    required this.episode,
    required this.onRefillToWatch,
  });

  @override
  Widget build(BuildContext context) {
    // Construir URL de thumbnail de Mux
    final thumbnailUrl =
        'https://image.mux.com/${episode.playBlackId}/thumbnail.jpg';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        //col,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen del video
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              thumbnailUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[900],
                  child: const Icon(
                    Icons.movie_outlined,
                    color: Colors.grey,
                    size: 60,
                  ),
                );
              },
            ),
          ),
          // Botón Refill To Watch
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRefillToWatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Refill To Watch',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*class VideoScrollableView extends StatefulWidget {
  final List<Episode> videos;

  const VideoScrollableView({super.key, required this.videos});

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  late PageController _pageController;
  bool _isModalVisible = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Resetear el estado del modal cuando cambia la página
    setState(() {
      _isModalVisible = false;
    });
  }

  void _onModalVisibilityChanged(bool isVisible) {
    setState(() {
      _isModalVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: _isModalVisible
          ? const NeverScrollableScrollPhysics()
          : BouncingScrollPhysics(),
      onPageChanged: _onPageChanged,
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final Episode videoPost = widget.videos[index];

        return _VideoPage(
          videoPost: videoPost,
          onModalVisibilityChanged: _onModalVisibilityChanged,
          onRedirectBack: () {
            if (index > 0) {
              _pageController.animateToPage(
                index - 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
              );
            }
          },
        );
      },
    );
  }
}

class _VideoPage extends StatefulWidget {
  final Episode videoPost;
  final ValueChanged<bool>? onModalVisibilityChanged;
  final VoidCallback? onRedirectBack;

  const _VideoPage({
    required this.videoPost,
    this.onModalVisibilityChanged,
    this.onRedirectBack,
  });

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  bool _showRefillModal = false;
  bool _showQuickRefills = false;
  bool _isExiting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Si es el episodio 10, iniciar timer para mostrar el modal después de 2 segundos
    if (widget.videoPost.episodeNumber == 10) {
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          context.read<MoviesCubit>().togglePlay();
          setState(() {
            _showRefillModal = true;
          });
          widget.onModalVisibilityChanged?.call(true);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onRefillToWatch() {
    setState(() {
      _showRefillModal = false;
      _showQuickRefills = true;
    });
    // El modal sigue visible (QuickRefillsWidget), así que mantener el scroll deshabilitado
    widget.onModalVisibilityChanged?.call(true);
  }

  void _onCloseQuickRefills() {
    setState(() {
      _showQuickRefills = false;
    });
    widget.onModalVisibilityChanged?.call(false);

    widget.onRedirectBack?.call();
  }

  void _onCloseModal() async {
    setState(() => _isExiting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _showRefillModal = false;
      _showQuickRefills = false;
    });
    widget.onModalVisibilityChanged?.call(false);
    widget.onRedirectBack?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //video player + gradientes
        SizedBox.expand(
            child: FullScreenPlayer(
          videoUrl: widget.videoPost.episodeUrl,
          caption: widget.videoPost.episodeNumber.toString(),
        )),

        // Icono de pause/play centrado y botones - se muestran/ocultan según el estado
        BlocBuilder<MoviesCubit, MoviesState>(
          builder: (context, state) {
            if (!state.showVideoButtons) {
              return const SizedBox.shrink();
            }

            // Determinar si el video está reproduciendo
            final isPlaying = state.videoController?.value.isPlaying ?? false;

            return Stack(
              children: [
                // Gradiente oscuro en la parte inferior para el texto
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Icono de pause/play centrado
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.read<MoviesCubit>().togglePlay();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),

                // Botones de reacción (primero, a la derecha)
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: VideoButtons(video: widget.videoPost),
                ),
                // Información del video (título y descripción) en la parte inferior izquierda
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 80, // Menos espacio para dar más ancho a _VideoInfo
                  child: _VideoInfo(
                    title: 'Flash Marrige ${widget.videoPost.episodeNumber}',
                    description:
                        'A flash marriage" synopsis typically involves a fast, often unexpected marriage between strangers or acquaintances, common in Chinese web novels and dramas like Flash Marriage: The Big Shots Pampered Wife, where a heroine (like Bella) enters a contract marriage with a powerful CEO (Jesse) for convenience (revenge, family, business), only for genuine romance to blossom amidst corporate rivals and challenges, turning their fake union into real love',
                    currentEpisode: 11,
                    totalEpisodes: widget.videoPost.episodeNumber,
                  ),
                ),
                // Barra de progreso (debajo de VideoButtons y _VideoInfo)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: state.videoController != null
                      ? _VideoProgressBar(
                          controller: state.videoController!,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),

        if ((_showRefillModal || _showQuickRefills) &&
            widget.videoPost.episodeNumber == 10)
          FadeOut(
            animate: _isExiting,
            child: Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
        if (_showRefillModal && widget.videoPost.episodeNumber == 10)
          Stack(
            children: [
              Center(
                child: SlideInUp(
                  duration: const Duration(milliseconds: 500),
                  child: _isExiting
                      ? FadeOutDown(
                          duration: const Duration(milliseconds: 500),
                          child: _RefillModal(
                            episode: widget.videoPost,
                            onRefillToWatch: _onRefillToWatch,
                          ),
                        )
                      : SlideInUp(
                          duration: const Duration(milliseconds: 500),
                          child: _RefillModal(
                            episode: widget.videoPost,
                            onRefillToWatch: _onRefillToWatch,
                          ),
                        ),
                ),
              ),
              // Botón X para cerrar en la esquina superior derecha
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: FadeOut(
                  animate: _isExiting,
                  child: GestureDetector(
                    onTap: _onCloseModal,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        // QuickRefillsWidget cuando se hace click en Refill To Watch
        if (_showQuickRefills && widget.videoPost.episodeNumber == 10)
          Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideInUp(
                  duration: const Duration(milliseconds: 500),
                  child: const QuickRefillsWidget(),
                ),
              ),
              // Botón X para cerrar QuickRefillsWidget en la esquina superior derecha
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: GestureDetector(
                  onTap: _onCloseQuickRefills,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}





*/

/* NOTAS IMPORTANTES
  el page view no se deben cargar mas de tres vistas ya que son recuros de memoria no utilizados

el video player necesita un controllador , se maneja dentro de una statefull widget
ese controldor vadentro del estate 
un state full si tiene un ciclo de vida 
inicia initstate

 */
