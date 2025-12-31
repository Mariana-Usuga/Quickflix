import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/models/profile.dart';
import 'package:quickflix/services/local_video_services.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final LocalVideoServices localVideoServices;

  ProfileCubit({required this.localVideoServices})
      : super(const ProfileState());

  /// Obtiene el perfil del usuario autenticado
  Future<void> loadUserProfile(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final profile = await localVideoServices.getProfileById(userId);
      emit(state.copyWith(
        profile: profile,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      print('Error al cargar perfil del usuario: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Agrega coins al perfil del usuario
  Future<void> addCoins(String userId, int coins) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Actualizar las coins en la base de datos
      await localVideoServices.addCoinsToProfile(userId, coins);

      // Recargar el perfil para obtener el valor actualizado
      await loadUserProfile(userId);
    } catch (e) {
      print('Error al agregar coins: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Resta coins del perfil del usuario
  /// Retorna true si se pudo restar, false si no tiene suficientes coins
  Future<bool> subtractCoins(String userId, int coins) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Restar las coins en la base de datos
      final success =
          await localVideoServices.subtractCoinsFromProfile(userId, coins);

      // Recargar el perfil para obtener el valor actualizado
      await loadUserProfile(userId);

      return success;
    } catch (e) {
      print('Error al restar coins: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      return false;
    }
  }
}
