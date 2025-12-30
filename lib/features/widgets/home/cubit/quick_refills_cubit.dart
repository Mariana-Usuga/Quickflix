import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'quick_refills_state.dart';

class QuickRefillsCubit extends Cubit<QuickRefillsState> {
  QuickRefillsCubit() : super(const QuickRefillsState()) {
    loadOfferings();
  }

  Future<void> loadOfferings() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

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

      emit(state.copyWith(
        offering: offering,
        customerInfo: customerInfo,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> purchasePackage(Package package) async {
    try {
      emit(state.copyWith(isLoading: true));

      final purchaserInfo = await Purchases.purchasePackage(package);

      // Actualizar la información del cliente después de la compra
      emit(state.copyWith(
        customerInfo: purchaserInfo.customerInfo,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
      ));
      // Re-lanzar el error para que el widget pueda manejarlo
      rethrow;
    }
  }
}

