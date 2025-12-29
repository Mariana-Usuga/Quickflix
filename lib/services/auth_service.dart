// 1. IMPORTANTE: Estos imports son obligatorios para que se quiten las líneas rojas
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // 2. Definimos el cliente de Supabase (esto arregla el error de _supabase)
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      const webClientId =
          '954467020673-2e7a3gk6s92ob6akvnb0jppq2pt6a24e.apps.googleusercontent.com';
      //'954467020673-etgd04a6138cell6i2dsfk4n9rcec6do.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: webClientId,
      );

      // 1️⃣ Autenticación Google usando authenticate()
      // Este método puede lanzar GoogleSignInException si el usuario cancela
      GoogleSignInAccount googleAccount;
      try {
        googleAccount = await googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        // Si el usuario cancela, la excepción se lanza aquí
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return null;
        }
        rethrow;
      }

      // 2️⃣ Obtener ID Token
      final googleAuth = googleAccount.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Missing Google ID token');
      }

      // 3️⃣ Login en Supabase (SIN accessToken)
      return await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } on GoogleSignInException catch (e) {
      // Usuario canceló la autenticación
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } on PlatformException catch (e) {
      // Usuario canceló (fallback para otros casos)
      if (e.message?.toLowerCase().contains('cancel') == true) {
        return null;
      }
      rethrow;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /*Future<AuthResponse> signInWithGoogle() async {
    // 3. Tu ID de cliente WEB (el que copiaste de Google Cloud)
    // REEMPLAZA ESTO CON TU ID REAL
    try {
      const webClientId =
          '954467020673-etgd04a6138cell6i2dsfk4n9rcec6do.apps.googleusercontent.com';

      // 4. Configuración
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(serverClientId: webClientId);

      // 5. Abrir ventana de Google
      //final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final googleAccount = await googleSignIn.authenticate();
      final googleAuthorization =
          await googleAccount.authorizationClient.authorizationForScopes([
        'email',
        'profile',
        'openid',
      ]);
      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;
      final accessToken = googleAuthorization?.accessToken;

      // 6. Obtener credenciales
      /*final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;*/
      if (accessToken == null) {
        throw 'No se encontró el Access Token de Google';
      }
      if (idToken == null) {
        throw 'No se encontró el ID Token de Google';
      }

      // 7. Enviar a Supabase
      return _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Error durante la autenticación con Google: $e');
    }
  }*/

  // Función para cerrar sesión
  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
