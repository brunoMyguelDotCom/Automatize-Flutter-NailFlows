import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/dados_do_agendamento.dart';
import '../modelos/servico.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import '../widgets/estado_vazio.dart';

class AgendamentoFormPage extends StatefulWidget {
  const AgendamentoFormPage({
    super.key,
    required this.repositorio,
    this.agendamento,
    this.diaSugerido,
  });

  final AgendaRepository repositorio;
  final Agendamento? agendamento;
  final DateTime? diaSugerido;

  bool get ehEdicao => agendamento != null;

  @override
  State<AgendamentoFormPage> createState() => _AgendamentoFormPageState();
}

class _AgendamentoFormPageState extends State<AgendamentoFormPage> {
  List<Cliente> _clientes = [];
  List<Servico> _servicos = [];

  Cliente? _cliente;
  Servico? _servico;
  late DateTime _dia;
  late TimeOfDay _hora;

  bool _carregando = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final agendamento = widget.agendamento;

    if (agendamento != null) {
      _dia = inicioDoDia(agendamento.inicio);
      _hora = TimeOfDay(
        hour: agendamento.inicio.hour,
        minute: agendamento.inicio.minute,
      );
    } else {
      final sugerido = _primeiroHorarioLivre(
        widget.diaSugerido ?? DateTime.now(),
      );
      _dia = inicioDoDia(sugerido);
      _hora = TimeOfDay(hour: sugerido.hour, minute: 0);
    }
    _carregar();
  }

  DateTime _primeiroHorarioLivre(DateTime dia) {
    final agora = DateTime.now();
    final noveDaManha = DateTime(dia.year, dia.month, dia.day, 9);

    if (noveDaManha.isAfter(agora)) return noveDaManha;

    final proximaHora = DateTime(
      agora.year,
      agora.month,
      agora.day,
      agora.hour + 1,
    );

    if (proximaHora.day != agora.day || proximaHora.hour >= 21) {
      final amanha = agora.add(const Duration(days: 1));
      return DateTime(amanha.year, amanha.month, amanha.day, 9);
    }

    return proximaHora;
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final clientes = await widget.repositorio.listarClientes();
      final servicos = await widget.repositorio.listarServicos();
      if (!mounted) return;

      final agendamento = widget.agendamento;
      setState(() {
        _clientes = clientes;
        _servicos = servicos;
        _cliente = agendamento == null
            ? null
            : clientes.firstWhere(
                (c) => c.email == agendamento.cliente.email,
                orElse: () => agendamento.cliente,
              );
        _servico = agendamento == null
            ? null
            : servicos.firstWhere(
                (s) => s.nome == agendamento.servico.nome,
                orElse: () => agendamento.servico,
              );
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

  DateTime get _inicio =>
      DateTime(_dia.year, _dia.month, _dia.day, _hora.hour, _hora.minute);

  Future<void> _escolherDia() async {
    final escolhido = await showDatePicker(
      context: context,
      initialDate: _dia,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Dia do atendimento',
    );
    if (escolhido != null) setState(() => _dia = escolhido);
  }

  Future<void> _escolherHora() async {
    final escolhida = await showTimePicker(
      context: context,
      initialTime: _hora,
      helpText: 'Horário de início',
    );
    if (escolhida != null) setState(() => _hora = escolhida);
  }

  Future<void> _salvar() async {
    if (_cliente == null || _servico == null) {
      setState(() => _erro = 'Escolha a cliente e o serviço.');
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final dados = DadosDoAgendamento(
      cliente: _cliente!,
      servico: _servico!,
      inicio: _inicio,
      duracaoMinutos: _servico!.duracaoMinutos,
    );

    try {
      if (widget.ehEdicao) {
        await widget.repositorio.atualizarAgendamento(
          widget.agendamento!.id,
          dados,
        );
      } else {
        await widget.repositorio.criarAgendamento(dados);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro.toString();
        _salvando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ehEdicao ? 'Editar atendimento' : 'Novo atendimento',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _corpo(),
        ),
      ),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
    }

    if (_clientes.isEmpty) {
      return const EstadoVazio(
        icone: Icons.people_outline_rounded,
        titulo: 'Nenhuma cliente cadastrada',
        descricao: 'Cadastre uma cliente antes de marcar um atendimento.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        _Rotulo('Cliente'),
        DropdownButtonFormField<Cliente>(
          initialValue: _cliente,
          isExpanded: true,
          decoration: _decoracao(Icons.person_outline_rounded),
          hint: const Text('Escolha a cliente'),
          items: _clientes
              .map(
                (cliente) => DropdownMenuItem(
                  value: cliente,
                  child: Text(cliente.nome, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (cliente) => setState(() => _cliente = cliente),
        ),
        const SizedBox(height: 18),
        _Rotulo('Serviço'),
        DropdownButtonFormField<Servico>(
          initialValue: _servico,
          isExpanded: true,
          decoration: _decoracao(Icons.spa_outlined),
          hint: const Text('Escolha o serviço'),
          items: _servicos
              .map(
                (servico) => DropdownMenuItem(
                  value: servico,
                  child: Text(
                    '${servico.nome}  ·  '
                    '${duracaoPorExtenso(servico.duracaoMinutos)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (servico) => setState(() => _servico = servico),
        ),
        const SizedBox(height: 18),
        _Rotulo('Quando'),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _Seletor(
                icone: Icons.event_rounded,
                valor: diaPorExtenso(_dia),
                aoTocar: _escolherDia,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _Seletor(
                icone: Icons.schedule_rounded,
                valor: _hora.format(context),
                aoTocar: _escolherHora,
              ),
            ),
          ],
        ),
        if (_servico != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: rosaClaro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.timelapse_rounded, size: 18, color: vinho),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Dura ${duracaoPorExtenso(_servico!.duracaoMinutos)} '
                    'e termina às '
                    '${hora(_inicio.add(Duration(minutes: _servico!.duracaoMinutos)))}',
                    style: const TextStyle(fontSize: 14, color: texto),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_erro != null) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: recusadoFundo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: recusado,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _erro!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: recusado,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _salvando ? null : _salvar,
            style: FilledButton.styleFrom(backgroundColor: vinho),
            icon: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(
              widget.ehEdicao ? 'Salvar alterações' : 'Marcar atendimento',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoracao(IconData icone) {
    OutlineInputBorder borda(Color cor) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor),
    );

    return InputDecoration(
      prefixIcon: Icon(icone, color: textoApoio),
      filled: true,
      fillColor: superficie,
      border: borda(linha),
      enabledBorder: borda(linha),
      focusedBorder: borda(vinho),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

class _Seletor extends StatelessWidget {
  const _Seletor({
    required this.icone,
    required this.valor,
    required this.aoTocar,
  });

  final IconData icone;
  final String valor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: superficie,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: linha),
          ),
          child: Row(
            children: [
              Icon(icone, size: 20, color: textoApoio),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: texto),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
