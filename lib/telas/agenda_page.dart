import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/agendamento.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../util/datas.dart';
import '../widgets/cartao_atendimento.dart';
import '../widgets/estado_vazio.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key, required this.repositorio});

  final AgendaRepository repositorio;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _dia = inicioDoDia(DateTime.now());
  List<Agendamento> _agendamentos = [];
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
      final lista = await widget.repositorio.listarAgendamentos(
        inicio: inicioDoDia(_dia),
        fim: fimDoDia(_dia),
      );
      if (!mounted) return;
      setState(() {
        _agendamentos = lista;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não consegui carregar a agenda. Sem internet?';
        _carregando = false;
      });
    }
  }

  void _mudarDia(int dias) {
    setState(() => _dia = _dia.add(Duration(days: dias)));
    _carregar();
  }

  void _irParaHoje() {
    setState(() => _dia = inicioDoDia(DateTime.now()));
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final ehHoje = mesmoDia(_dia, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Cabecalho(
                dia: _dia,
                ehHoje: ehHoje,
                agendamentos: _agendamentos,
                aoVoltarDia: () => _mudarDia(-1),
                aoAvancarDia: () => _mudarDia(1),
                aoIrParaHoje: _irParaHoje,
              ),
              Expanded(child: _corpo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return EstadoVazio(
        icone: Icons.wifi_off_rounded,
        titulo: _erro!,
        acao: FilledButton(
          onPressed: _carregar,
          child: const Text('Tentar de novo'),
        ),
      );
    }

    if (_agendamentos.isEmpty) {
      return const EstadoVazio(
        icone: Icons.spa_outlined,
        titulo: 'Nenhum atendimento nesse dia',
        descricao: 'Dia livre na agenda.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      itemCount: _agendamentos.length,
      separatorBuilder: (context, indice) => const SizedBox(height: 10),
      itemBuilder: (context, indice) {
        final agendamento = _agendamentos[indice];
        return CartaoAtendimento(agendamento: agendamento, aoTocar: () {});
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.dia,
    required this.ehHoje,
    required this.agendamentos,
    required this.aoVoltarDia,
    required this.aoAvancarDia,
    required this.aoIrParaHoje,
  });

  final DateTime dia;
  final bool ehHoje;
  final List<Agendamento> agendamentos;
  final VoidCallback aoVoltarDia;
  final VoidCallback aoAvancarDia;
  final VoidCallback aoIrParaHoje;

  @override
  Widget build(BuildContext context) {
    final ativos = agendamentos.where((a) => a.ativo).toList();
    final total = ativos.fold<double>(0, (soma, a) => soma + (a.preco ?? 0));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: rosaClaro,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(diaPorExtenso(dia), style: estiloTitulo())),
              IconButton(
                onPressed: aoVoltarDia,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Dia anterior',
                color: vinho,
              ),
              IconButton(
                onPressed: aoAvancarDia,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Próximo dia',
                color: vinho,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  _resumo(ativos.length, total),
                  style: const TextStyle(fontSize: 13.5, color: textoApoio),
                ),
              ),
              if (!ehHoje)
                TextButton(onPressed: aoIrParaHoje, child: const Text('Hoje')),
            ],
          ),
        ],
      ),
    );
  }

  String _resumo(int quantidade, double total) {
    if (quantidade == 0) return 'Nenhum atendimento';
    final atendimentos = quantidade == 1
        ? '1 atendimento'
        : '$quantidade atendimentos';
    if (total == 0) return atendimentos;
    return '$atendimentos  ·  R\$ ${total.toStringAsFixed(2)}';
  }
}
