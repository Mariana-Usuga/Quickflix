// lib/features/auth/cubit/auth_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickflix/models/user.dart';
import 'package:quickflix/models/profile.dart';
import 'package:quickflix/services/local_video_services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase/supabase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SupabaseClient supabase;
  final LocalVideoServices? localVideoServices;

  // Callbacks para resetear otros cubits
  VoidCallback? _onResetHistory;
  VoidCallback? _onResetInsights;
  VoidCallback? _onResetProfile;
  VoidCallback? _onResetUpload;

  AuthCubit(this.supabase, {this.localVideoServices}) : super(AuthLoading()) {
    // Emitir AuthLoading mientras se verifica la sesión
    _checkInitialSession();

    supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        // --- ¡CORRECCIÓN CLAVE! ---
        // Call our centralized function to handle login/refresh.
        _updateAuthWithSubscription(session.user);
      } else {
        // The user has signed out.
        _handleSignOut();
      }
    });
  }

  Future<void> _checkInitialSession() async {
    // Check if there's already a saved session
    final session = supabase.auth.currentSession;

    if (session != null) {
      await _updateAuthWithSubscription(session.user);
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _updateAuthWithSubscription(User user) async {
    try {
      await Purchases.logIn(user.id);

      final userEntity = UserEntity(
        id: user.id,
        email: user.email!,
      );

      // Intentar cargar el perfil si tenemos el servicio
      Profile? profile;
      if (localVideoServices != null) {
        try {
          profile = await localVideoServices!.getProfileById(user.id);
        } catch (e) {
          print("Error al cargar perfil: $e");
          // Continuar sin perfil si hay error
        }
      }

      emit(AuthSuccess(userEntity, profile: profile));
    } catch (e) {
      print("RevenueCat error updating subscription: $e");
      emit(AuthSuccess(UserEntity(id: user.id, email: user.email!)));
    }
  }

  Future<void> refreshUserSubscription() async {
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      await _updateAuthWithSubscription(currentUser);
    }
  }

  /// Configura los callbacks para resetear otros cubits
  void setResetCallbacks({
    VoidCallback? onResetHistory,
    VoidCallback? onResetInsights,
    VoidCallback? onResetProfile,
    VoidCallback? onResetUpload,
  }) {
    _onResetHistory = onResetHistory;
    _onResetInsights = onResetInsights;
    _onResetProfile = onResetProfile;
    _onResetUpload = onResetUpload;
  }

  /// Resetea todos los cubits configurados
  void _resetAllCubits() {
    _onResetHistory?.call();
    _onResetInsights?.call();
    _onResetProfile?.call();
    _onResetUpload?.call();
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // The magic is now done by the onAuthStateChange listener, which will call
      // _updateAuthWithSubscription automatically. You don't need to do anything else.
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      // We no longer save 'plan_type' in Supabase.
      // RevenueCat will assign the 'free' plan by default.
      await supabase.auth.signUp(
        email: email,
        password: password,
      );
      // The onAuthStateChange listener will handle the rest.
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      print("AuthCubit: Error al hacer logout en RevenueCat: $e");
    }

    // Resetear todos los cubits antes de emitir Unauthenticated
    _resetAllCubits();
    emit(Unauthenticated());
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();

    // Resetear todos los cubits antes de emitir Unauthenticated
    _resetAllCubits();
    emit(Unauthenticated());
  }
}
