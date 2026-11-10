import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modelos/agendamento.dart';
import '../tema/cores.dart';
import '../util/whatsapp.dart';

/// Mostra a mensagem de confirmação pronta para a profissional revisar,
/// editar se quiser e mandar no WhatsApp da cliente.
class AvisoWhatsappPage extends StatefulWidget {
  const AvisoWhatsappPage({
    super.key,
    required this.agendamento,
    this.abrirLink,
  });

  final Agendamento agendamento;

  /// Usado nos testes para não abrir o navegador de verdade.
  final Future<bool> Function(Uri)? abrirLink;

  @override
  State<AvisoWhatsappPage> createState() => _AvisoWhatsappPageState();
}

class _AvisoWhatsappPageState extends State<AvisoWhatsappPage> {
  late final _mensagem = TextEditingController(
    text: mensagemDeConfirmacao(widget.agendamento),
  );

  String? get _numero =>
      numeroParaWhatsapp(widget.agendamento.cliente.telefone);

  @override
  void dispose() {
    _mensagem.dispose();
    super.dispose();
  }

  Future<void> _abrirWhatsapp() async {
    final numero = _numero;
    if (numero == null) return;

    final link = linkDoWhatsapp(numero, _mensagem.text);
    final abrir =
        widget.abrirLink ??
        (Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
    final abriu = await abrir(link);

    if (!abriu && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não consegui abrir o WhatsApp. Copie a mensagem.'),
          backgroundColor: recusado,
        ),
      );
    }
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _mensagem.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mensagem copiada'),
        backgroundColor: vinhoEscuro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.agendamento.cliente;

    return Scaffold(
      appBar: AppBar(title: Text('Mensagem para ${cliente.primeiroNome}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _corpo(),
        ),
      ),
    );
  }

  Widget _corpo() {
    final semNumero = _numero == null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        const Text(
          'Revise o texto e mude o que quiser antes de enviar.',
          style: TextStyle(fontSize: 13.5, color: textoApoio),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _mensagem,
          minLines: 10,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 14.5, height: 1.4, color: texto),
          decoration: InputDecoration(
            filled: true,
            fillColor: superficie,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: linha),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: linha),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: vinho),
            ),
          ),
        ),
        if (semNumero) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: recusadoFundo,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'A cliente não tem telefone completo no cadastro. '
              'Copie a mensagem e mande por onde preferir.',
              style: TextStyle(fontSize: 13.5, color: recusado),
            ),
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: semNumero ? null : _abrirWhatsapp,
            style: FilledButton.styleFrom(backgroundColor: vinho),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              'Abrir no WhatsApp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _copiar,
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copiar mensagem'),
          style: OutlinedButton.styleFrom(
            foregroundColor: vinho,
            side: const BorderSide(color: rosa),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
