import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dados/agenda_repository.dart';
import '../modelos/cliente.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../util/telefone.dart';
import '../widgets/avatar_cliente.dart';
import '../widgets/campo_formulario.dart';
import 'cliente_historico_page.dart';

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key, required this.repositorio, this.cliente});

  final AgendaRepository repositorio;
  final Cliente? cliente;

  bool get ehEdicao => cliente != null;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;
  late final TextEditingController _telefone;

  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    _nome = TextEditingController(text: cliente?.nome ?? '');
    _email = TextEditingController(text: cliente?.email ?? '');
    _telefone = TextEditingController(
      text: formatarTelefone(cliente?.telefone ?? ''),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final dados = Cliente(
      id: widget.cliente?.id,
      nome: _nome.text.trim(),
      email: _email.text.trim(),
      telefone: _telefone.text.trim(),
      observacao: widget.cliente?.observacao,
    );

    try {
      if (widget.ehEdicao) {
        await widget.repositorio.atualizarCliente(widget.cliente!.id!, dados);
      } else {
        await widget.repositorio.criarCliente(dados);
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
        title: const Text('Excluir cliente'),
        content: Text('Excluir ${widget.cliente!.nome} do cadastro?'),
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
      await widget.repositorio.excluirCliente(widget.cliente!.id!);
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

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ClienteHistoricoPage(
          cliente: widget.cliente!,
          repositorio: widget.repositorio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ehEdicao ? 'Cliente' : 'Nova cliente'),
        actions: [
          if (widget.ehEdicao)
            IconButton(
              onPressed: _abrirHistorico,
              icon: const Icon(Icons.history_rounded),
              tooltip: 'Histórico de atendimentos',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formulario,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                if (cliente != null) ...[
                  Center(child: AvatarCliente(cliente: cliente, tamanho: 72)),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(cliente.nome, style: estiloTitulo(tamanho: 22)),
                  ),
                  const SizedBox(height: 22),
                ],
                CampoFormulario(
                  controlador: _nome,
                  rotulo: 'Nome',
                  dica: 'Ex.: Maria Silva',
                  icone: Icons.person_outline_rounded,
                  validador: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome da cliente';
                    }
                    return null;
                  },
                ),
                CampoFormulario(
                  controlador: _email,
                  rotulo: 'E-mail',
                  dica: 'maria@email.com',
                  icone: Icons.mail_outline_rounded,
                  teclado: TextInputType.emailAddress,
                  validador: (valor) {
                    final texto = valor?.trim() ?? '';
                    if (texto.isEmpty) return 'Informe o e-mail';
                    if (!texto.contains('@') || !texto.contains('.')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                CampoFormulario(
                  controlador: _telefone,
                  rotulo: 'Telefone',
                  dica: '+55 44 99999-9999',
                  icone: Icons.phone_outlined,
                  teclado: TextInputType.phone,
                  formatadores: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneOuCelularInputFormatter(),
                  ],
                  validador: (valor) {
                    final texto = valor?.trim() ?? '';
                    if (texto.isEmpty) return 'Informe o telefone';
                    if (!telefoneCompleto(texto)) {
                      return 'Telefone incompleto';
                    }
                    return null;
                  },
                ),
                if (cliente?.observacao != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: douradoFundo,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: dourado,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cliente!.observacao!,
                            style: const TextStyle(fontSize: 14, color: texto),
                          ),
                        ),
                      ],
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
                    label: const Text('Excluir cliente'),
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
