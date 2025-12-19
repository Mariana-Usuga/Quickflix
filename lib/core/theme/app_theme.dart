import 'package:flutter/material.dart';

class AppTheme{

  ThemeData gettheme()=> ThemeData(
     useMaterial3: true,
     brightness: Brightness.dark,
     // Color de fondo por defecto del tema oscuro en Material 3
     // Es un gris muy oscuro: Color(0xFF121212)
     scaffoldBackgroundColor: const Color(0xFF121212), // Color por defecto de Brightness.dark en Material 3
  );
 
}

