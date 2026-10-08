import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/servico.dart';
import '../tema/cores.dart';
import '../util/datas.dart';

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

  Future<void> _carregar() async {
    final lista = await widget.repositorio.listarServicos();
    if (!mounted) return;
    setState(() {
      _servicos = lista;
      _carregando = false;
    });
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
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _servicos.length,
      separatorBuilder: (context, i) => const SizedBox(height: 12),
      itemBuilder: (context, indice) {
        final servico = _servicos[indice];

        return Container(
          padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(fontSize: 13, color: textoApoio),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
