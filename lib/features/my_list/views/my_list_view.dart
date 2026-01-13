import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/shared/cubits/titles/titles_cubit.dart';
import 'package:quickflix/features/my_list/widgets/saved_list.dart';
import 'package:quickflix/features/my_list/widgets/watching_list.dart';
import 'package:quickflix/features/profile/cubit/profile_cubit.dart';
import 'package:quickflix/features/auth/cubit/auth_cubit.dart';

class MyListView extends StatefulWidget {
  const MyListView({super.key});

  @override
  State<MyListView> createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Obtener el user ID del AuthCubit (más confiable que ProfileCubit)
    final authState = context.read<AuthCubit>().state;
    String? profileId;

    if (authState is AuthSuccess) {
      profileId = authState.user.id;
    } else {
      // Si no está autenticado, intentar obtener del ProfileCubit como fallback
      final profile = context.read<ProfileCubit>().state.profile;
      profileId = profile?.id;
    }

    // Solo cargar los videos si tenemos un profileId válido
    if (profileId != null) {
      final cubit = context.read<MoviesCubit>();
      cubit.loadSavedVideosByProfileId(profileId);
      cubit.loadWatchingVideosByProfileId(profileId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    // Escuchar cambios en el perfil para cargar videos cuando esté disponible
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, profileState) {
        final profileId = profileState.profile?.id;
        if (profileId != null) {
          final cubit = context.read<MoviesCubit>();
          cubit.loadSavedVideosByProfileId(profileId);
          cubit.loadWatchingVideosByProfileId(profileId);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Heart icon
                    Image.asset(
                      'assets/clipsyLogo1.png',
                      //width: logoSize,
                      //height: logoSize,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 40),
                    // Title
                    Text(
                      'My List',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: 'Saved'),
                  Tab(text: 'Watching'),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SavedList(
                      profileId:
                          '8057f308-db04-4775-8219-a882a6a4e5d6', // TODO: Obtener del usuario autenticado
                    ),
                    WatchingList(
                      profileId:
                          '8057f308-db04-4775-8219-a882a6a4e5d6', // TODO: Obtener del usuario autenticado
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
