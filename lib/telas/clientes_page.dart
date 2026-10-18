import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/cliente.dart';
import '../tema/cores.dart';
import '../widgets/avatar_cliente.dart';
import '../widgets/estado_vazio.dart';
import 'cliente_form_page.dart';
import 'cliente_historico_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key, required this.repositorio});

  final AgendaRepository repositorio;

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final TextEditingController _buscaController = TextEditingController();
  List<Cliente> _clientes = [];
  bool _carregando = true;
  String? _erro;
  String _busca = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final lista = await widget.repositorio.listarClientes();
      if (!mounted) return;
      setState(() {
        _clientes = lista;
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

  List<Cliente> get _filtrados {
    if (_busca.trim().isEmpty) return _clientes;
    final termo = _busca.toLowerCase();
    return _clientes
        .where((c) => c.nome.toLowerCase().contains(termo))
        .toList();
  }

  Future<void> _abrirFicha([Cliente? cliente]) async {
    final mudou = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) =>
            ClienteFormPage(repositorio: widget.repositorio, cliente: cliente),
      ),
    );

    if (mudou == true) {
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro atualizado'),
          backgroundColor: vinhoEscuro,
        ),
      );
    }
  }

  void _abrirHistorico(Cliente cliente) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ClienteHistoricoPage(
          cliente: cliente,
          repositorio: widget.repositorio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFicha(),
        backgroundColor: vinho,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nova cliente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: TextField(
              controller: _buscaController,
              onChanged: (valor) => setState(() => _busca = valor),
              decoration: InputDecoration(
                hintText: 'Buscar cliente',
                prefixIcon: const Icon(Icons.search_rounded, color: textoApoio),
                filled: true,
                fillColor: superficie,
                border: _borda(linha),
                enabledBorder: _borda(linha),
                focusedBorder: _borda(vinho),
              ),
            ),
          ),
          Expanded(child: _corpo()),
        ],
      ),
    );
  }

  OutlineInputBorder _borda(Color cor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
    }

    if (_erro != null) {
      return EstadoVazio(
        icone: Icons.wifi_off_rounded,
        titulo: 'Não consegui carregar as clientes',
        descricao: _erro,
        acao: FilledButton(
          onPressed: _carregar,
          child: const Text('Tentar de novo'),
        ),
      );
    }

    final clientes = _filtrados;

    if (clientes.isEmpty) {
      return EstadoVazio(
        icone: _busca.isEmpty
            ? Icons.people_outline_rounded
            : Icons.person_search_outlined,
        titulo: _busca.isEmpty
            ? 'Nenhuma cliente cadastrada'
            : 'Nenhuma cliente com esse nome',
        descricao: _busca.isEmpty ? 'Cadastre a primeira pelo botão.' : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: clientes.length,
      separatorBuilder: (context, i) => const SizedBox(height: 10),
      itemBuilder: (context, indice) {
        final cliente = clientes[indice];
        return _CartaoCliente(
          cliente: cliente,
          aoAbrirFicha: () => _abrirFicha(cliente),
          aoAbrirHistorico: () => _abrirHistorico(cliente),
        );
      },
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  const _CartaoCliente({
    required this.cliente,
    required this.aoAbrirFicha,
    required this.aoAbrirHistorico,
  });

  final Cliente cliente;
  final VoidCallback aoAbrirFicha;
  final VoidCallback aoAbrirHistorico;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoAbrirFicha,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: superficie,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: linha),
            boxShadow: sombraCartao,
          ),
          child: Row(
            children: [
              AvatarCliente(cliente: cliente, tamanho: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: texto,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cliente.telefone ?? cliente.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: textoApoio),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: aoAbrirFicha,
                icon: const Icon(Icons.edit_outlined),
                color: vinho,
                tooltip: 'Ver e editar',
              ),
              IconButton(
                onPressed: aoAbrirHistorico,
                icon: const Icon(Icons.history_rounded),
                color: textoApoio,
                tooltip: 'Histórico de atendimentos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
