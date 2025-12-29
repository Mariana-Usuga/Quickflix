import 'package:flutter/foundation.dart';
import 'package:quickflix/features/auth/cubit/auth_cubit.dart';

/// ChangeNotifier que escucha los cambios del AuthCubit para actualizar el router
class AuthListener extends ChangeNotifier {
  final AuthCubit authCubit;

  AuthListener(this.authCubit) {
    // Escuchar los cambios del AuthCubit
    authCubit.stream.listen((_) {
      notifyListeners();
    });
  }
}
