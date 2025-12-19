import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el ancho de la pantalla
    final double screenWidth = MediaQuery.of(context).size.width;

    // ---------------------------------------------------------
    // CÁLCULOS DE TAMAÑO (Porcentaje + Clamp)
    // ---------------------------------------------------------

    // Padding Horizontal:
    // Intenta ser el 5%, pero nunca menos de 15px ni más de 30px
    final double horizontalPadding = (screenWidth * 0.02).clamp(15.0, 30.0);

    // Logo:
    // Intenta ser el 60%, pero mantiene un rango entre 50px y 80px
    final double logoSize = (screenWidth * 0.60).clamp(50.0, 80.0);

    // Iconos (Campana/Cartera):
    // Intenta ser el 7.5%, pero mantiene un rango entre 24px y 30px
    final double iconSize = (screenWidth * 0.075).clamp(24.0, 30.0);

    // Espacio entre iconos:
    final double gapSize = (screenWidth * 0.03).clamp(8.0, 16.0);

    // Badge (Círculo rojo):
    final double badgeSize = (screenWidth * 0.045).clamp(14.0, 16.0);

    // Fuente del badge:
    final double badgeFontSize = (screenWidth * 0.025).clamp(9.0, 11.0);

    return Padding(
      //padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ------------------ LOGO ------------------
          Image.asset(
            'assets/clipsyLogo1.png',
            //width: logoSize,
            //height: logoSize,
            fit: BoxFit.contain,
          ),

          // ------------------ ICONOS ------------------
          Row(
            children: [
              // Botón Notificaciones
              IconButton(
                onPressed: () {},
                // Quitamos el padding por defecto para tener control total del tamaño
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
