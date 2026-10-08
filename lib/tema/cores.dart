import 'package:flutter/material.dart';

const Color vinho = Color(0xFF8D4F60);
const Color vinhoEscuro = Color(0xFF5C2F3C);
const Color rosa = Color(0xFFF8D7DF);
const Color rosaClaro = Color(0xFFFDECEF);
const Color rosaSuave = Color(0xFFFFF8FA);
const Color fundo = Color(0xFFFFF6F9);
const Color superficie = Color(0xFFFFFFFF);
const Color dourado = Color(0xFFC9A96B);
const Color douradoFundo = Color(0xFFFAF2E4);
const Color texto = Color(0xFF4E2C35);
const Color textoApoio = Color(0xFF7A6268);
const Color linha = Color(0xFFF0DCE2);

const Color pendente = Color(0xFFB98029);
const Color pendenteFundo = Color(0xFFFBEEDC);
const Color confirmado = Color(0xFF3F7A5E);
const Color confirmadoFundo = Color(0xFFE4F0EA);
const Color recusado = Color(0xFFB3453F);
const Color recusadoFundo = Color(0xFFFBE8E7);

const LinearGradient gradienteVinho = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [vinho, vinhoEscuro],
);

const List<BoxShadow> sombraCartao = [
  BoxShadow(color: Color(0x0F5C2F3C), blurRadius: 18, offset: Offset(0, 6)),
];
