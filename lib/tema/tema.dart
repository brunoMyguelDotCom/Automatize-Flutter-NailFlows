import 'package:flutter/material.dart';

import 'cores.dart';

const String fonteTitulo = 'Playfair Display';
const String fonteTexto = 'Montserrat';

ThemeData temaNailsFlow() {
  final base = ThemeData(
    colorSchemeSeed: vinho,
    scaffoldBackgroundColor: fundo,
    brightness: Brightness.light,
    fontFamily: fonteTexto,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: vinho,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: fonteTexto,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}

TextStyle estiloTitulo({double tamanho = 26, Color cor = texto}) {
  return TextStyle(
    fontFamily: fonteTitulo,
    fontSize: tamanho,
    fontWeight: FontWeight.w600,
    color: cor,
    height: 1.2,
  );
}
