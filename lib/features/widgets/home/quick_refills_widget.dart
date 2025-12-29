import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class QuickRefillsWidget extends StatefulWidget {
  const QuickRefillsWidget({super.key});

  @override
  State<QuickRefillsWidget> createState() => _QuickRefillsWidgetState();
}

class _QuickRefillsWidgetState extends State<QuickRefillsWidget> {
  Offering? _offering;
  CustomerInfo? _customerInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { 
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Obtener el offering "coins_offering"
      final offerings = await Purchases.getOfferings();
      Offering? offering;

      // Buscar el offering por identifier en el mapa 'all'
      offering = offerings.all['coins_offering'];

      // Si no se encuentra, usar el current si existe
      if (offering == null && offerings.current != null) {
        offering = offerings.current;
      }

      // Obtener información del cliente para el balance
      final customerInfo = await Purchases.getCustomerInfo();

      setState(() {
        _offering = offering;
        _customerInfo = customerInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final purchaserInfo = await Purchases.purchasePackage(package);

      // Actualizar la información del cliente después de la compra
      setState(() {
        _customerInfo = purchaserInfo.customerInfo;
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compra exitosa'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la compra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Obtener el balance de coins del usuario
  double _getBalance() {
    if (_customerInfo == null) return 0.0;
    // Buscar en los entitlements o nonSubscriptionTransactions
    // Por ahora, retornamos 0.99 como ejemplo, pero deberías obtenerlo de RevenueCat
    // basado en cómo almacenes el balance de coins
    return 0.99;
  }

  // Obtener el precio formateado
  String _getFormattedPrice(Package package) {
    return package.storeProduct.priceString;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Error: $_error',
          style: GoogleFonts.inter(color: Colors.red),
        ),
      );
    }

    if (_offering == null || _offering!.availablePackages.isEmpty) {
      return const SizedBox.shrink();
    }

    final packages = _offering!.availablePackages;
    final balance = _getBalance();

    // Obtener el precio del primer package para mostrar
    final firstPackagePrice =
        packages.isNotEmpty ? _getFormattedPrice(packages.first) : '\$0.00';

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
              final price = _getFormattedPrice(package);

              return GestureDetector(
                onTap: () => _purchasePackage(package),
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
  }
}
