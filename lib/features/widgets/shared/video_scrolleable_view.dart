import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/shared/cubits/titles/titles_cubit.dart';
import 'package:quickflix/features/auth/cubit/auth_cubit.dart';
import 'package:quickflix/features/profile/cubit/profile_cubit.dart';
import 'package:quickflix/features/widgets/home/quick_refills_widget.dart';
import 'package:quickflix/features/widgets/shared/video_buttons.dart';
import 'package:quickflix/features/widgets/video/fullscreen_player.dart';
import 'package:quickflix/shared/entities/episode.dart';
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
    // 1. Intentamos guardar el progreso del video actual antes de salir
    try {
      final profileId = context.read<ProfileCubit>().state.profile?.id;

      // Verificamos que tengamos un usuario y que el índice sea válido
      if (profileId != null && _currentIndex < widget.videos.length) {
        final currentVideo = widget.videos[_currentIndex];

        // Llamamos al Cubit. No es necesario usar 'await' aquí
        // porque el Cubit seguirá ejecutando la tarea aunque el widget se destruya.
        context.read<MoviesCubit>().saveCurrentProgress(
              profileId: profileId,
              titleId: currentVideo.titleId,
              episodeId: currentVideo.id,
            );
      }
    } catch (e) {
      // Silenciamos cualquier error para evitar que la app se detenga al salir
      print('Error guardando progreso al cerrar: $e');
    }

    // 2. Limpieza normal de controladores
    _pageController.dispose();

    // 3. Siempre al final
    super.dispose();
  }

  void _onPageChanged(int index) {
    final profileId = context.read<ProfileCubit>().state.profile?.id;

    if (profileId != null) {
      // El video anterior es el que estaba en _currentIndex
      final previousVideo = widget.videos[_currentIndex];

      context.read<MoviesCubit>().saveCurrentProgress(
            profileId: profileId,
            titleId: previousVideo.titleId,
            episodeId: previousVideo.id,
          );
    }
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

  /// Verifica si se debe bloquear el scroll basado en el episodio y las monedas
  bool _shouldBlockScroll(int episodeNumber) {
    // Validar primero episodeNumber >= 10 (a partir del episodio 10)
    final isEpisode10OrHigher = episodeNumber >= 10;

    // Luego validar las monedas
    final profileCubit = context.read<ProfileCubit>();
    final profile = profileCubit.state.profile;
    const coinsPerEpisode = 2;
    final hasEnoughCoins = profile != null && profile.coins >= coinsPerEpisode;

    // Bloquear scroll si:
    // Es episodio 10 o superior Y no tiene suficientes monedas
    if (isEpisode10OrHigher && !hasEnoughCoins) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Usar BlocListener y BlocBuilder para escuchar cambios en ProfileCubit
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) {
        // Escuchar cuando las monedas aumentan y el modal está visible
        final previousCoins = previous.profile?.coins ?? 0;
        final currentCoins = current.profile?.coins ?? 0;
        return currentCoins > previousCoins && _isModalVisible;
      },
      listener: (context, state) {
        // Si las monedas aumentaron y el modal está visible, actualizar el estado
        if (state.profile != null && state.profile!.coins >= 2) {
          setState(() {
            _isModalVisible = false;
          });
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          // Reconstruir cuando cambien las monedas del perfil o cuando cambie el perfil
          final previousCoins = previous.profile?.coins ?? 0;
          final currentCoins = current.profile?.coins ?? 0;
          final coinsChanged = previousCoins != currentCoins;
          final profileChanged = previous.profile != current.profile;
          return coinsChanged || profileChanged;
        },
        builder: (context, profileState) {
          // Verificar si se debe bloquear el scroll para el episodio actual
          final currentEpisode = _currentIndex < widget.videos.length
              ? widget.videos[_currentIndex].episodeNumber
              : 0;
          final shouldBlockScroll = _shouldBlockScroll(currentEpisode);

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            // Deshabilitar scroll si el modal está visible o si no hay suficientes monedas
            physics: (_isModalVisible || shouldBlockScroll)
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
        },
      ),
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

    // Validar y descontar monedas desde el capítulo 10 en adelante
    if (widget.videoPost.episodeNumber == 10) {
      // Para el episodio 10, esperar 2 segundos antes de validar
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _validateCoinsAndShowModal();
        }
      });
    } else if (widget.videoPost.episodeNumber > 10) {
      // Para episodios superiores a 10, validar y descontar inmediatamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _validateCoinsAndShowModal();
        }
      });
    }
  }

  /// Valida si el usuario tiene suficientes monedas (2 por episodio)
  /// Si tiene, descuenta las monedas. Si no tiene, muestra el modal de refill
  Future<void> _validateCoinsAndShowModal() async {
    if (!mounted) return;

    const coinsPerEpisode = 2;
    final profileCubit = context.read<ProfileCubit>();
    final profile = profileCubit.state.profile;
    final authState = context.read<AuthCubit>().state;

    // Si no está autenticado, mostrar modal
    if (authState is! AuthSuccess) {
      _displayRefillModal();
      return;
    }

    // Si no hay perfil cargado, intentar cargarlo primero
    if (profile == null) {
      await profileCubit.loadUserProfile(authState.user.id);
      if (!mounted) return;
      final updatedProfile = profileCubit.state.profile;
      if (updatedProfile == null || updatedProfile.coins < coinsPerEpisode) {
        _displayRefillModal();
        return;
      }
    }

    final currentProfile = profileCubit.state.profile;
    if (currentProfile == null) {
      _displayRefillModal();
      return;
    }

    // Validar si tiene suficientes monedas
    if (currentProfile.coins >= coinsPerEpisode) {
      // Si tiene suficientes monedas, descontarlas
      final success =
          await profileCubit.subtractCoins(authState.user.id, coinsPerEpisode);
      if (!mounted) return;

      if (!success) {
        // Si no se pudo restar, mostrar modal
        _displayRefillModal();
      } else {
        // Si se descontó exitosamente, cerrar el modal si está abierto
        if (_showRefillModal || _showQuickRefills) {
          setState(() {
            _showRefillModal = false;
            _showQuickRefills = false;
          });
          widget.onModalVisibilityChanged?.call(false);
        }
      }
    } else {
      // No tiene suficientes monedas, mostrar modal
      _displayRefillModal();
    }
  }

  /// Muestra el modal de refill y pausa el video
  void _displayRefillModal() {
    if (!mounted) return;

    // Pausar el video
    context.read<MoviesCubit>().togglePlayPause();
    setState(() {
      _showRefillModal = true;
    });
    widget.onModalVisibilityChanged?.call(true);
  }

  /// Verifica si se debe mostrar el modal
  /// Primero valida episodeNumber == 10, luego las monedas
  bool _shouldShowModal() {
    // Validar primero episodeNumber >= 10 (a partir del episodio 10)
    final isEpisode10OrHigher = widget.videoPost.episodeNumber >= 10;

    // Luego validar las monedas
    final profileCubit = context.read<ProfileCubit>();
    final profile = profileCubit.state.profile;
    const coinsPerEpisode = 2;
    final hasEnoughCoins = profile != null && profile.coins >= coinsPerEpisode;

    // Mostrar modal si:
    // 1. Es episodio 10 Y no tiene suficientes monedas
    // 2. O si no tiene suficientes monedas (a partir del episodio 10, es decir, episodio 10 o superior)
    if (isEpisode10OrHigher && !hasEnoughCoins) {
      return true;
    }

    return false;
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
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) {
        // Escuchar cuando las monedas aumentan (después de una compra)
        final previousCoins = previous.profile?.coins ?? 0;
        final currentCoins = current.profile?.coins ?? 0;
        // Solo escuchar si las monedas aumentaron y el modal está visible
        return currentCoins > previousCoins &&
            (_showRefillModal || _showQuickRefills);
      },
      listener: (context, state) {
        // Si las monedas aumentaron y el modal está visible, validar de nuevo
        if (state.profile != null && state.profile!.coins >= 2) {
          // Validar y descontar monedas de nuevo
          // Esto cerrará el modal automáticamente si tiene suficientes monedas
          _validateCoinsAndShowModal();
        }
      },
      child: Stack(
        children: [
          //video player + gradientes
          SizedBox.expand(
              child: FullScreenPlayer(
            videoUrl: widget.videoPost.episodeUrl,
            caption: widget.videoPost.episodeNumber.toString(),
            overlay: BlocBuilder<MoviesCubit, MoviesState>(
              buildWhen: (previous, current) {
                // Solo reconstruir cuando cambie el controller o el estado de inicialización
                return previous.videoController != current.videoController ||
                    previous.isVideoInitialized != current.isVideoInitialized;
              },
              builder: (context, videoState) {
                return Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child:
                      videoState.controller != null && videoState.isInitialized
                          ? _VideoProgressBar(
                              controller: videoState.controller!,
                            )
                          : const SizedBox.shrink(),
                );
              },
            ),
          )),

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
          if ((_showRefillModal || _showQuickRefills) && _shouldShowModal())
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
              ),
            ),

          // Modal de Refill
          // Validar primero episodeNumber == 10, luego las monedas
          if (_showRefillModal && _shouldShowModal())
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
          if (_showQuickRefills && _shouldShowModal())
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
      ),
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
