import 'package:flutter/material.dart';

import '../modelos/cliente.dart';
import '../tema/cores.dart';

class AvatarCliente extends StatelessWidget {
  const AvatarCliente({super.key, required this.cliente, this.tamanho = 42});

  final Cliente cliente;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: rosa, shape: BoxShape.circle),
      child: Text(
        cliente.iniciais,
        style: TextStyle(
          fontSize: tamanho * 0.36,
          fontWeight: FontWeight.w700,
          color: vinhoEscuro,
        ),
      ),
    );
  }
}
