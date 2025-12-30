import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickflix/features/auth/cubit/auth_cubit.dart';
import 'package:quickflix/features/profile/cubit/profile_cubit.dart';
import 'package:quickflix/services/local_video_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el perfil cuando se muestra la pantalla
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      final localVideoServices = LocalVideoServices();
      final profileCubit = ProfileCubit(localVideoServices: localVideoServices);
      profileCubit.loadUserProfile(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthCubit>().state;
    final localVideoServices = LocalVideoServices();

    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit(localVideoServices: localVideoServices);
        if (authState is AuthSuccess) {
          cubit.loadUserProfile(authState.user.id);
        }
        return cubit;
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final profile = profileState.profile;

              return Scaffold(
                backgroundColor: Colors.black,
                body: SafeArea(
                  child: Column(
                    children: [
                      // Top bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // App logo
                            Image.asset(
                              'assets/clipsyLogo1.png',
                              height: 28,
                            ),
                            Text(
                              'Profile',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Space notifita',
                              style: TextStyle(color: Colors.black),
                            ),
                            // Notification icon with badge
                            /*Visibility(
                    visible: true,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 6,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '50',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),*/
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Avatar and name
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profile?.photoProfile != null &&
                                profile!.photoProfile!.isNotEmpty
                            ? NetworkImage(profile.photoProfile!)
                            : const AssetImage('assets/logo.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey.shade800,
                        onBackgroundImageError: (_, __) {
                          // Si falla la carga de la imagen, usar la imagen por defecto
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authState is AuthSuccess
                            ? authState.user.email
                            : 'User',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Balance card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F1F1F),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'My Balance:',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.monetization_on,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      profile?.coins.toString() ?? '0',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Details',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white54,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Settings list
                              _SettingsCard(
                                children: [
                                  const _SettingsTile(title: 'Subscription'),
                                  _SettingsTile(
                                    title: 'Terms of Use',
                                    onTap: () {
                                      context.push('/home/3/terms-of-use');
                                    },
                                  ),
                                  _SettingsTile(
                                    title: 'Privacy Policy',
                                    onTap: () {
                                      context.push('/home/3/privacy-policy');
                                    },
                                  ),
                                  const _SettingsTile(title: 'Notifications'),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Sign out button (disabled look)
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F1F1F),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign Out',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
