import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/servico.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import '../widgets/estado_vazio.dart';
import 'servico_form_page.dart';

class ServicosPage extends StatefulWidget {
  const ServicosPage({super.key, required this.repositorio});

  final AgendaRepository repositorio;

  @override
  State<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  List<Servico> _servicos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  String? _erro;

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await widget.repositorio.listarServicos();
      if (!mounted) return;
      setState(() {
        _servicos = lista;
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

  Future<void> _abrirFicha([Servico? servico]) async {
    final mudou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            ServicoFormPage(repositorio: widget.repositorio, servico: servico),
      ),
    );

    if (mudou == true) {
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catálogo atualizado'),
          backgroundColor: vinhoEscuro,
        ),
      );
    }
  }

  IconData _icone(Servico servico) {
    final nome = servico.nome.toLowerCase();
    if (nome.contains('molde')) return Icons.auto_fix_high_rounded;
    if (nome.contains('gel')) return Icons.brush_rounded;
    if (nome.contains('blindagem')) return Icons.shield_outlined;
    return Icons.spa_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFicha(),
        backgroundColor: vinho,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo serviço'),
      ),
      body: _corpo(),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
    }

    if (_erro != null) {
      return EstadoVazio(
        icone: Icons.wifi_off_rounded,
        titulo: 'Não consegui carregar os serviços',
        descricao: _erro,
        acao: FilledButton(
          onPressed: _carregar,
          child: const Text('Tentar de novo'),
        ),
      );
    }

    if (_servicos.isEmpty) {
      return const EstadoVazio(
        icone: Icons.spa_outlined,
        titulo: 'Nenhum serviço cadastrado',
        descricao: 'Cadastre o primeiro pelo botão.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _servicos.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, indice) {
        final servico = _servicos[indice];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _abrirFicha(servico),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                color: superficie,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: linha),
                boxShadow: sombraCartao,
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rosaClaro,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(_icone(servico), color: vinho, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          servico.nome,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: texto,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Duração de ${duracaoPorExtenso(servico.duracaoMinutos)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textoApoio,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _abrirFicha(servico),
                    icon: const Icon(Icons.edit_outlined),
                    color: vinho,
                    tooltip: 'Ver e editar',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
