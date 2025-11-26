//DEPENDENCIA PARA FORMATEO DE NUMERO intl

import 'package:intl/intl.dart';

class TextFormatter {
//NOTA: CUANDO SE CREA UNA CLASE ESTATITA NO HAY QUE HACER UNA INSTANCIA PARA USAR SUS METODOS
  static String textReadeableNumber(double number) {

    //para esto es necesario el paquete intl
    final formatterNumber = NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: ' ',
    ).format(number);

    return formatterNumber;
  }
}

