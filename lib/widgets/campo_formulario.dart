import 'package:flutter/material.dart';

import '../tema/cores.dart';

class CampoFormulario extends StatelessWidget {
  const CampoFormulario({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.dica,
    this.icone,
    this.teclado,
    this.validador,
  });

  final TextEditingController controlador;
  final String rotulo;
  final String? dica;
  final IconData? icone;
  final TextInputType? teclado;
  final String? Function(String?)? validador;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controlador,
        keyboardType: teclado,
        validator: validador,
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: dica,
          prefixIcon: icone == null ? null : Icon(icone, color: textoApoio),
          filled: true,
          fillColor: superficie,
          border: _borda(linha),
          enabledBorder: _borda(linha),
          focusedBorder: _borda(vinho),
          errorBorder: _borda(recusado),
          focusedErrorBorder: _borda(recusado),
        ),
      ),
    );
  }

  OutlineInputBorder _borda(Color cor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor),
    );
  }
}
