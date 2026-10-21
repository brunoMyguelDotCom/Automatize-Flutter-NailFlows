import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dados/agenda_repository.dart';
import '../modelos/servico.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import '../widgets/campo_formulario.dart';

class ServicoFormPage extends StatefulWidget {
  const ServicoFormPage({super.key, required this.repositorio, this.servico});

  final AgendaRepository repositorio;
  final Servico? servico;

  bool get ehEdicao => servico != null;

  @override
  State<ServicoFormPage> createState() => _ServicoFormPageState();
}

class _ServicoFormPageState extends State<ServicoFormPage> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _duracao;

  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.servico?.nome ?? '');
    _duracao = TextEditingController(
      text: widget.servico?.duracaoMinutos.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _duracao.dispose();
    super.dispose();
  }

  int get _minutos => int.tryParse(_duracao.text.trim()) ?? 0;

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final dados = Servico(
      id: widget.servico?.id ?? '',
      nome: _nome.text.trim(),
      duracaoMinutos: _minutos,
    );

    try {
      if (widget.ehEdicao) {
        await widget.repositorio.atualizarServico(widget.servico!.id, dados);
      } else {
        await widget.repositorio.criarServico(dados);
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

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir serviço'),
        content: Text('Tirar ${widget.servico!.nome} do catálogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: recusado),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      await widget.repositorio.excluirServico(widget.servico!.id);
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
      appBar: AppBar(title: Text(widget.ehEdicao ? 'Serviço' : 'Novo serviço')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formulario,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                CampoFormulario(
                  controlador: _nome,
                  rotulo: 'Nome do serviço',
                  dica: 'Ex.: Molde F1',
                  icone: Icons.spa_outlined,
                  validador: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome do serviço';
                    }
                    return null;
                  },
                ),
                CampoFormulario(
                  controlador: _duracao,
                  rotulo: 'Duração em minutos',
                  dica: '150',
                  icone: Icons.timelapse_rounded,
                  teclado: TextInputType.number,
                  formatadores: [FilteringTextInputFormatter.digitsOnly],
                  validador: (valor) {
                    final minutos = int.tryParse(valor?.trim() ?? '') ?? 0;
                    if (minutos <= 0) return 'Informe a duração em minutos';
                    if (minutos > 600) return 'Duração muito longa';
                    return null;
                  },
                ),
                if (_minutos > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Equivale a ${duracaoPorExtenso(_minutos)} de atendimento.',
                      style: const TextStyle(fontSize: 13, color: textoApoio),
                    ),
                  ),
                if (_erro != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                      widget.ehEdicao ? 'Salvar alterações' : 'Cadastrar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (widget.ehEdicao) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _salvando ? null : _excluir,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Excluir serviço'),
                    style: TextButton.styleFrom(foregroundColor: recusado),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
