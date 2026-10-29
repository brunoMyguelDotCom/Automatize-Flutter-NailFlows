import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/agendamento.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../util/datas.dart';
import '../widgets/cartao_atendimento.dart';
import '../widgets/estado_vazio.dart';
import '../widgets/faixa_de_dias.dart';
import 'agendamento_form_page.dart';
import 'detalhe_atendimento_page.dart';

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

  void _selecionarDia(DateTime dia) {
    setState(() => _dia = inicioDoDia(dia));
    _carregar();
  }

  void _mudarSemana(int semanas) {
    _selecionarDia(_dia.add(Duration(days: 7 * semanas)));
  }

  Future<void> _escolherNoCalendario() async {
    final escolhido = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: 'Ir para uma data',
    );

    if (escolhido != null) _selecionarDia(escolhido);
  }

  Future<void> _novoAtendimento() async {
    final criou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => AgendamentoFormPage(
          repositorio: widget.repositorio,
          diaSugerido: _dia,
        ),
      ),
    );

    if (criou == true) {
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimento marcado'),
          backgroundColor: vinhoEscuro,
        ),
      );
    }
  }

  Future<void> _abrirDetalhe(Agendamento agendamento) async {
    final mudou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => DetalheAtendimentoPage(
          agendamento: agendamento,
          repositorio: widget.repositorio,
        ),
      ),
    );

    if (mudou == true) await _carregar();
  }

  Agendamento? get _proximo {
    if (!mesmoDia(_dia, DateTime.now())) return null;
    final agora = DateTime.now();
    for (final agendamento in _agendamentos) {
      if (agendamento.ativo && agendamento.fim.isAfter(agora)) {
        return agendamento;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novoAtendimento,
        backgroundColor: vinho,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo atendimento'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Cabecalho(
            dia: _dia,
            agendamentos: _agendamentos,
            aoSelecionarDia: _selecionarDia,
            aoIrParaHoje: () => _selecionarDia(DateTime.now()),
            aoVoltarSemana: () => _mudarSemana(-1),
            aoAvancarSemana: () => _mudarSemana(1),
            aoAbrirCalendario: _escolherNoCalendario,
          ),
          Expanded(child: _corpo()),
        ],
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
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

    final proximo = _proximo;

    return RefreshIndicator(
      color: vinho,
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: _agendamentos.length,
        separatorBuilder: (context, indice) => const SizedBox(height: 12),
        itemBuilder: (context, indice) {
          final agendamento = _agendamentos[indice];
          return CartaoAtendimento(
            agendamento: agendamento,
            proximo: agendamento.id == proximo?.id,
            aoTocar: () => _abrirDetalhe(agendamento),
          );
        },
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.dia,
    required this.agendamentos,
    required this.aoSelecionarDia,
    required this.aoIrParaHoje,
    required this.aoVoltarSemana,
    required this.aoAvancarSemana,
    required this.aoAbrirCalendario,
  });

  final DateTime dia;
  final List<Agendamento> agendamentos;
  final ValueChanged<DateTime> aoSelecionarDia;
  final VoidCallback aoIrParaHoje;
  final VoidCallback aoVoltarSemana;
  final VoidCallback aoAvancarSemana;
  final VoidCallback aoAbrirCalendario;

  @override
  Widget build(BuildContext context) {
    final ehHoje = mesmoDia(dia, DateTime.now());
    final ativos = agendamentos.where((a) => a.ativo).toList();
    final confirmados = ativos
        .where((a) => a.statusConvite == StatusConvite.confirmado)
        .length;
    final pendentes = ativos
        .where((a) => a.statusConvite == StatusConvite.pendente)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: rosaClaro,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rosa),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diaPorExtenso(dia), style: estiloTitulo()),
                    const SizedBox(height: 4),
                    Text(
                      _resumo(ativos.length, confirmados, pendentes),
                      style: const TextStyle(fontSize: 13.5, color: textoApoio),
                    ),
                  ],
                ),
              ),
              if (!ehHoje)
                TextButton.icon(
                  onPressed: aoIrParaHoje,
                  icon: const Icon(Icons.today_rounded, size: 18),
                  label: const Text('Hoje'),
                  style: TextButton.styleFrom(foregroundColor: vinho),
                ),
              IconButton(
                onPressed: aoAbrirCalendario,
                icon: const Icon(Icons.calendar_month_rounded),
                color: vinho,
                tooltip: 'Escolher uma data',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _BotaoDeSemana(
                icone: Icons.chevron_left_rounded,
                dica: 'Semana anterior',
                aoTocar: aoVoltarSemana,
              ),
              Expanded(
                child: FaixaDeDias(
                  diaSelecionado: dia,
                  aoSelecionar: aoSelecionarDia,
                ),
              ),
              _BotaoDeSemana(
                icone: Icons.chevron_right_rounded,
                dica: 'Próxima semana',
                aoTocar: aoAvancarSemana,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _intervaloDaSemana(dia),
              style: const TextStyle(fontSize: 12, color: textoApoio),
            ),
          ),
        ],
      ),
    );
  }

  String _resumo(int quantidade, int confirmados, int pendentes) {
    if (quantidade == 0) return 'Nenhum atendimento';

    final atendimentos = quantidade == 1
        ? '1 atendimento'
        : '$quantidade atendimentos';
    final detalhes = <String>[];
    if (confirmados > 0) {
      detalhes.add('$confirmados confirmado${confirmados > 1 ? 's' : ''}');
    }
    if (pendentes > 0) {
      detalhes.add('$pendentes aguardando resposta');
    }

    if (detalhes.isEmpty) return atendimentos;
    return '$atendimentos  ·  ${detalhes.join('  ·  ')}';
  }

  String _intervaloDaSemana(DateTime dia) {
    final dias = semanaDe(dia);
    final primeiro = dias.first;
    final ultimo = dias.last;

    if (primeiro.month == ultimo.month) {
      return '${primeiro.day} a ${ultimo.day} de ${mesPorExtenso(ultimo)}';
    }

    return '${primeiro.day} de ${mesPorExtenso(primeiro)} a '
        '${ultimo.day} de ${mesPorExtenso(ultimo)}';
  }
}

class _BotaoDeSemana extends StatelessWidget {
  const _BotaoDeSemana({
    required this.icone,
    required this.dica,
    required this.aoTocar,
  });

  final IconData icone;
  final String dica;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: aoTocar,
      icon: Icon(icone),
      color: vinho,
      tooltip: dica,
      visualDensity: VisualDensity.compact,
    );
  }
}
