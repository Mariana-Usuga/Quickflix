import 'package:purchases_flutter/models/package_wrapper.dart';

int getCoinsFromPackage(Package package) {
  // Aquí usas los Identifiers que pusiste en RevenueCat
  switch (package.identifier) {
    case 'coins_100_pkg':
      return 100;
    case 'coins_550_pkg':
      return 550;
    case 'coins_900_pkg':
      return 900;
    default:
      return 0;
  }
}
