import 'package:flutter/material.dart';

import '../modelos/agendamento.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../util/datas.dart';
import '../widgets/etiqueta.dart';

class DetalheAtendimentoPage extends StatelessWidget {
  const DetalheAtendimentoPage({super.key, required this.agendamento});

  final Agendamento agendamento;

  @override
  Widget build(BuildContext context) {
    final cliente = agendamento.cliente;

    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: gradienteVinho,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cliente.iniciais,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cliente.nome,
                            style: estiloTitulo(tamanho: 22, cor: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            agendamento.servico.nome,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _Secao('Horário'),
              _Linha(
                icone: Icons.event_rounded,
                rotulo: 'Dia',
                valor: diaPorExtenso(agendamento.inicio),
              ),
              _Linha(
                icone: Icons.schedule_rounded,
                rotulo: 'Horário',
                valor: faixaDeHorario(agendamento.inicio, agendamento.fim),
              ),
              _Linha(
                icone: Icons.timelapse_rounded,
                rotulo: 'Duração',
                valor: duracaoPorExtenso(agendamento.duracaoMinutos),
              ),
              const SizedBox(height: 18),
              const _Secao('Situação'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        'Resposta da cliente',
                        style: TextStyle(fontSize: 14, color: textoApoio),
                      ),
                    ),
                    Etiqueta.doAgendamento(agendamento),
                  ],
                ),
              ),
              _Linha(
                icone: Icons.flag_outlined,
                rotulo: 'Situação atual',
                valor: agendamento.situacao.rotulo,
              ),
              if (agendamento.ultimaSincronizacao != null)
                _Linha(
                  icone: Icons.sync_rounded,
                  rotulo: 'Sincronizado',
                  valor:
                      '${diaPorExtenso(agendamento.ultimaSincronizacao!)} às '
                      '${hora(agendamento.ultimaSincronizacao!)}',
                ),
              const SizedBox(height: 18),
              const _Secao('Cliente'),
              _Linha(
                icone: Icons.mail_outline_rounded,
                rotulo: 'E-mail',
                valor: cliente.email,
              ),
              if (cliente.telefone != null)
                _Linha(
                  icone: Icons.phone_outlined,
                  rotulo: 'Telefone',
                  valor: cliente.telefone!,
                ),
              if (cliente.observacao != null)
                _Linha(
                  icone: Icons.info_outline_rounded,
                  rotulo: 'Observação',
                  valor: cliente.observacao!,
                ),
              if (agendamento.observacao != null) ...[
                const SizedBox(height: 18),
                const _Secao('Anotação do atendimento'),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: rosaSuave,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: linha),
                  ),
                  child: Text(
                    agendamento.observacao!,
                    style: const TextStyle(fontSize: 14, color: texto),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _emBreve(context, 'Editar atendimento'),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vinho,
                        side: const BorderSide(color: rosa),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _emBreve(context, 'Cancelar atendimento'),
                      icon: const Icon(Icons.event_busy_outlined, size: 18),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: recusado,
                        side: const BorderSide(color: recusadoFundo),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _emBreve(context, 'Avisar pelo WhatsApp'),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Avisar a cliente'),
                style: FilledButton.styleFrom(
                  backgroundColor: vinho,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _emBreve(BuildContext context, String acao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$acao: ainda não implementado'),
        backgroundColor: vinhoEscuro,
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: vinho,
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: linha)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: textoApoio),
          const SizedBox(width: 10),
          SizedBox(
            width: 118,
            child: Text(
              rotulo,
              style: const TextStyle(fontSize: 14, color: textoApoio),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: texto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
