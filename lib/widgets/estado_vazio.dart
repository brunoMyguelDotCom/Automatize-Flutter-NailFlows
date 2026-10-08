import 'package:flutter/material.dart';

import '../tema/cores.dart';

class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String? descricao;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: rosaClaro,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 30, color: vinho),
            ),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: texto,
              ),
            ),
            if (descricao != null) ...[
              const SizedBox(height: 6),
              Text(
                descricao!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: textoApoio),
              ),
            ],
            if (acao != null) ...[const SizedBox(height: 18), acao!],
          ],
        ),
      ),
    );
  }
}
