import 'package:flutter/material.dart';

import '../modelos/agendamento.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import 'avatar_cliente.dart';
import 'etiqueta.dart';

class CartaoAtendimento extends StatelessWidget {
  const CartaoAtendimento({
    super.key,
    required this.agendamento,
    required this.aoTocar,
    this.proximo = false,
  });

  final Agendamento agendamento;
  final VoidCallback aoTocar;
  final bool proximo;

  @override
  Widget build(BuildContext context) {
    final cancelado = agendamento.situacao == SituacaoAtendimento.cancelado;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: superficie,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: proximo ? dourado : linha),
            boxShadow: sombraCartao,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (proximo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: douradoFundo,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: dourado),
                      const SizedBox(width: 6),
                      Text(
                        'Próximo atendimento',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: dourado.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: LayoutBuilder(
                  builder: (context, restricoes) {
                    final estreito = restricoes.maxWidth < 380;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 52,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hora(agendamento.inicio),
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: vinho,
                                ),
                              ),
                              Text(
                                hora(agendamento.fim),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textoApoio,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 44,
                          margin: const EdgeInsets.only(right: 14),
                          decoration: BoxDecoration(
                            color: cancelado ? linha : rosa,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AvatarCliente(cliente: agendamento.cliente),
                        const SizedBox(width: 12),
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
                              const SizedBox(height: 3),
                              Text(
                                '${agendamento.servico.nome}  ·  '
                                '${duracaoPorExtenso(agendamento.duracaoMinutos)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textoApoio,
                                ),
                              ),
                              if (estreito) ...[
                                const SizedBox(height: 8),
                                Etiqueta.doAgendamento(agendamento),
                              ],
                            ],
                          ),
                        ),
                        if (!estreito) ...[
                          const SizedBox(width: 10),
                          Etiqueta.doAgendamento(agendamento),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
