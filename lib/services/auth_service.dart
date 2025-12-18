// 1. IMPORTANTE: Estos imports son obligatorios para que se quiten las líneas rojas
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // 2. Definimos el cliente de Supabase (esto arregla el error de _supabase)
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithGoogle() async {
    // 3. Tu ID de cliente WEB (el que copiaste de Google Cloud)
    // REEMPLAZA ESTO CON TU ID REAL
    const webClientId =
        '262763476635-g858fckh4af46st094mpsmb21le0i954.apps.googleusercontent.com';

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
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
