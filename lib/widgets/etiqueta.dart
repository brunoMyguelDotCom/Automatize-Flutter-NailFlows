import 'package:flutter/material.dart';

import '../modelos/agendamento.dart';
import '../tema/cores.dart';

class Etiqueta extends StatelessWidget {
  const Etiqueta({
    super.key,
    required this.texto,
    required this.cor,
    required this.corDeFundo,
  });

  final String texto;
  final Color cor;
  final Color corDeFundo;

  factory Etiqueta.doAgendamento(Agendamento agendamento) {
    if (!agendamento.ativo) {
      return Etiqueta(
        texto: agendamento.situacao.rotulo,
        cor: agendamento.situacao == SituacaoAtendimento.concluido
            ? confirmado
            : recusado,
        corDeFundo: agendamento.situacao == SituacaoAtendimento.concluido
            ? confirmadoFundo
            : recusadoFundo,
      );
    }

    switch (agendamento.statusConvite) {
      case StatusConvite.confirmado:
        return const Etiqueta(
          texto: 'Confirmado',
          cor: confirmado,
          corDeFundo: confirmadoFundo,
        );
      case StatusConvite.recusado:
        return const Etiqueta(
          texto: 'Recusado',
          cor: recusado,
          corDeFundo: recusadoFundo,
        );
      case StatusConvite.talvez:
      case StatusConvite.pendente:
        return Etiqueta(
          texto: agendamento.statusConvite.rotulo,
          cor: pendente,
          corDeFundo: pendenteFundo,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: corDeFundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
