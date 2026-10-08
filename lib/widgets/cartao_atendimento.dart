import 'package:flutter/material.dart';

import '../modelos/agendamento.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import 'etiqueta.dart';

class CartaoAtendimento extends StatelessWidget {
  const CartaoAtendimento({
    super.key,
    required this.agendamento,
    required this.aoTocar,
  });

  final Agendamento agendamento;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cancelado = agendamento.situacao == SituacaoAtendimento.cancelado;

    return InkWell(
      onTap: aoTocar,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: superficie,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: linha),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hora(agendamento.inicio),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: vinho,
                    ),
                  ),
                  Text(
                    hora(agendamento.fim),
                    style: const TextStyle(fontSize: 12, color: textoApoio),
                  ),
                ],
              ),
            ),
            Container(
              width: 3,
              height: 42,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: cancelado ? linha : rosa,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agendamento.cliente.nome,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: texto,
                      decoration: cancelado
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    agendamento.servico.nome,
                    style: const TextStyle(fontSize: 13, color: textoApoio),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Etiqueta.doAgendamento(agendamento),
          ],
        ),
      ),
    );
  }
}
