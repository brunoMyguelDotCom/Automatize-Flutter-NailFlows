import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dados/cadastro_por_convite.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import '../util/whatsapp.dart';

/// Texto que vai junto do link quando a Cris manda pelo WhatsApp.
String mensagemDoLinkDeCadastro(String link) {
  return 'Oi! Aqui é a $nomeDaProfissional 💅\n'
      'Pra fazer seu cadastro e agendar comigo, é só preencher seus dados '
      'neste link:\n'
      '$link\n'
      '\n'
      'O link vale por 6 horas.';
}

/// Gera um convite na API e mostra o link para copiar ou mandar no WhatsApp.
class LinkDeCadastroDialog extends StatefulWidget {
  const LinkDeCadastroDialog({
    super.key,
    required this.convites,
    this.abrirLink,
  });

  final CadastroPorConvite convites;

  /// Usado nos testes para não abrir o WhatsApp de verdade.
  final Future<bool> Function(Uri)? abrirLink;

  @override
  State<LinkDeCadastroDialog> createState() => _LinkDeCadastroDialogState();
}

class _LinkDeCadastroDialogState extends State<LinkDeCadastroDialog> {
  ConviteDeCadastro? _convite;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _gerar();
  }

  Future<void> _gerar() async {
    setState(() {
      _convite = null;
      _erro = null;
    });
    try {
      final convite = await widget.convites.gerarLink();
      if (!mounted) return;
      setState(() => _convite = convite);
    } catch (erro) {
      if (!mounted) return;
      setState(() => _erro = erro.toString());
    }
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _convite!.link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado'),
        backgroundColor: vinhoEscuro,
      ),
    );
  }

  Future<void> _mandarNoWhatsapp() async {
    // Sem número: o WhatsApp abre a lista de conversas para a Cris escolher.
    final link = Uri.https('wa.me', '/', {
      'text': mensagemDoLinkDeCadastro(_convite!.link),
    });
    final abrir =
        widget.abrirLink ??
        (Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
    await abrir(link);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Link de cadastro'),
      content: SizedBox(width: 420, child: _conteudo()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (_convite != null) ...[
          OutlinedButton.icon(
            onPressed: _copiar,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar'),
          ),
          FilledButton.icon(
            onPressed: _mandarNoWhatsapp,
            style: FilledButton.styleFrom(backgroundColor: vinho),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('WhatsApp'),
          ),
        ],
      ],
    );
  }

  Widget _conteudo() {
    if (_erro != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_erro!, style: const TextStyle(color: recusado)),
          const SizedBox(height: 12),
          TextButton(onPressed: _gerar, child: const Text('Tentar de novo')),
        ],
      );
    }

    final convite = _convite;
    if (convite == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(color: vinho)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mande para a cliente: ela abre, preenche nome, e-mail e WhatsApp, '
          'e o cadastro aparece aqui em Clientes.',
          style: TextStyle(fontSize: 14, height: 1.4, color: texto),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: rosaClaro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            convite.link,
            style: const TextStyle(fontSize: 13, color: vinhoEscuro),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Vale até ${hora(convite.expiraEm)} de '
          '${diaPorExtenso(convite.expiraEm).toLowerCase()} e serve para '
          'um cadastro só.',
          style: const TextStyle(fontSize: 13, color: textoApoio),
        ),
      ],
    );
  }
}
