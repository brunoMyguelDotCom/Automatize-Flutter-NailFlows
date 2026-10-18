import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../widgets/cartao_atendimento.dart';
import '../widgets/estado_vazio.dart';
import 'detalhe_atendimento_page.dart';

class ClienteHistoricoPage extends StatefulWidget {
  const ClienteHistoricoPage({
    super.key,
    required this.cliente,
    required this.repositorio,
  });

  final Cliente cliente;
  final AgendaRepository repositorio;

  @override
  State<ClienteHistoricoPage> createState() => _ClienteHistoricoPageState();
}

class _ClienteHistoricoPageState extends State<ClienteHistoricoPage> {
  List<Agendamento> _historico = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final todos = await widget.repositorio.listarAgendamentos();
      if (!mounted) return;
      setState(() {
        _historico = todos.where((a) => _ehDaCliente(a)).toList()
          ..sort((a, b) => b.inicio.compareTo(a.inicio));
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.toString();
        _carregando = false;
      });
    }
  }

  bool _ehDaCliente(Agendamento agendamento) {
    final cliente = widget.cliente;
    if (cliente.id != null && agendamento.cliente.id != null) {
      return agendamento.cliente.id == cliente.id;
    }
    return agendamento.cliente.email == cliente.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: rosaClaro,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: rosa),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.cliente.nome, style: estiloTitulo(tamanho: 21)),
                    const SizedBox(height: 4),
                    Text(
                      _resumo(),
                      style: const TextStyle(fontSize: 13.5, color: textoApoio),
                    ),
                  ],
                ),
              ),
              Expanded(child: _corpo()),
            ],
          ),
        ),
      ),
    );
  }

  String _resumo() {
    if (_carregando) return 'Carregando atendimentos…';
    if (_erro != null) return 'Não foi possível carregar';
    if (_historico.isEmpty) return 'Nenhum atendimento registrado';
    final concluidos = _historico
        .where((a) => a.situacao == SituacaoAtendimento.concluido)
        .length;
    final total = _historico.length == 1
        ? '1 atendimento'
        : '${_historico.length} atendimentos';
    if (concluidos == 0) return total;
    return '$total  ·  $concluidos concluído${concluidos > 1 ? 's' : ''}';
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
    }

    if (_erro != null) {
      return EstadoVazio(
        icone: Icons.wifi_off_rounded,
        titulo: 'Não consegui carregar o histórico',
        descricao: _erro,
        acao: FilledButton(
          onPressed: _carregar,
          child: const Text('Tentar de novo'),
        ),
      );
    }

    if (_historico.isEmpty) {
      return const EstadoVazio(
        icone: Icons.history_rounded,
        titulo: 'Nenhum atendimento ainda',
        descricao: 'Quando ela for atendida, aparece aqui.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      itemCount: _historico.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, indice) {
        final agendamento = _historico[indice];
        return CartaoAtendimento(
          agendamento: agendamento,
          aoTocar: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  DetalheAtendimentoPage(agendamento: agendamento),
            ),
          ),
        );
      },
    );
  }
}
