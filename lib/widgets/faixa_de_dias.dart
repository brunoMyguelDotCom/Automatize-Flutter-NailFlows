import 'package:flutter/material.dart';

import '../tema/cores.dart';
import '../util/datas.dart';

class FaixaDeDias extends StatelessWidget {
  const FaixaDeDias({
    super.key,
    required this.diaSelecionado,
    required this.aoSelecionar,
  });

  final DateTime diaSelecionado;
  final ValueChanged<DateTime> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    final dias = semanaDe(diaSelecionado);
    final hoje = DateTime.now();

    return Row(
      children: dias.map((dia) {
        final selecionado = mesmoDia(dia, diaSelecionado);
        final ehHoje = mesmoDia(dia, hoje);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => aoSelecionar(dia),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selecionado ? vinho : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selecionado
                          ? vinho
                          : (ehHoje ? rosa : Colors.transparent),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        diaCurto(dia),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selecionado ? Colors.white70 : textoApoio,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dia.day}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selecionado ? Colors.white : texto,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
