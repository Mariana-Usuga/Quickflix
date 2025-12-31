import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:quickflix/features/auth/cubit/auth_cubit.dart';
import 'package:quickflix/features/profile/cubit/profile_cubit.dart';
import 'package:quickflix/features/widgets/home/cubit/quick_refills_cubit.dart';
import 'package:quickflix/features/widgets/shared/get_coins_from_package.dart';

class QuickRefillsWidget extends StatelessWidget {
  const QuickRefillsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuickRefillsCubit(),
      child: const _QuickRefillsContent(),
    );
  }
}

class _QuickRefillsContent extends StatelessWidget {
  const _QuickRefillsContent();

  Future<void> _handlePurchase(BuildContext context, Package package) async {
    // 1. CAPTURAR los Cubits ANTES del await
    // Al guardarlos en variables, ya no dependemos del context después del await
    final quickRefillsCubit = context.read<QuickRefillsCubit>();
    final profileCubit = context.read<ProfileCubit>();
    //final authState = context.read<AuthCubit>().state;
    //final userId = authState is AuthSuccess ? authState.user.id : null;
    final userId = '8057f308-db04-4775-8219-a882a6a4e5d6';
    try {
      // 2. Ejecutar la compra directamente con RevenueCat
      final purchaserInfo = await Purchases.purchasePackage(package);

      // 3. Actualizar la información del cliente en el cubit después de la compra
      quickRefillsCubit.updateCustomerInfo(purchaserInfo.customerInfo);

      // 4. ACTUALIZAR DATOS (Esto se ejecuta siempre, aunque el widget no esté visible)
      if (userId != null) {
        final coinsToAdd = getCoinsFromPackage(package);
        if (coinsToAdd > 0) {
          // Ejecutamos la suma de monedas en la DB
          await profileCubit.addCoins(userId, coinsToAdd);

          // 5. Después de agregar las monedas, descontar el costo del episodio (2 monedas)
          const coinsPerEpisode = 2;
          await profileCubit.subtractCoins(userId, coinsPerEpisode);
        }
      }

      // 6. SOLO PARA LA UI: Usamos mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase successful! Coins added.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error en compra: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuickRefillsCubit, QuickRefillsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.error != null) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Error: ${state.error}',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          );
        }

        if (state.offering == null ||
            state.offering!.availablePackages.isEmpty) {
          return const SizedBox.shrink();
        }

        final packages = state.offering!.availablePackages;
        final balance = state.getBalance();

        // Obtener el precio del primer package para mostrar
        final firstPackagePrice = packages.isNotEmpty
            ? state.getFormattedPrice(packages.first)
            : '\$0.00';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Línea blanca delgada superior
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white.withOpacity(0.2),
              ),

              const SizedBox(height: 20),

              // Price y Balance
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Row(
                    children: [
                      Text(
                        'Price: ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        firstPackagePrice,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Balance
                  Row(
                    children: [
                      Text(
                        'Balance: ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Título "Quick Refills"
              Text(
                'Quick Refills',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Grid de packages
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: packages.length > 6 ? 6 : packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  final price = state.getFormattedPrice(package);

                  return GestureDetector(
                    onTap: () => _handlePurchase(context, package),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1F1F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            price,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
