part of 'quick_refills_cubit.dart';

class QuickRefillsState {
  final Offering? offering;
  final CustomerInfo? customerInfo;
  final bool isLoading;
  final String? error;

  const QuickRefillsState({
    this.offering,
    this.customerInfo,
    this.isLoading = false,
    this.error,
  });

  QuickRefillsState copyWith({
    Offering? offering,
    CustomerInfo? customerInfo,
    bool? isLoading,
    String? error,
  }) {
    return QuickRefillsState(
      offering: offering ?? this.offering,
      customerInfo: customerInfo ?? this.customerInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Obtener el balance de coins del usuario
  double getBalance() {
    if (customerInfo == null) return 0.0;
    // Buscar en los entitlements o nonSubscriptionTransactions
    // Por ahora, retornamos 0.99 como ejemplo, pero deberías obtenerlo de RevenueCat
    // basado en cómo almacenes el balance de coins
    return 0.99;
  }

  // Obtener el precio formateado
  String getFormattedPrice(Package package) {
    return package.storeProduct.priceString;
  }
}

