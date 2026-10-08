import 'package:flutter/material.dart';

import '../dados/agenda_repository.dart';
import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../util/datas.dart';
import '../widgets/avatar_cliente.dart';
import '../widgets/estado_vazio.dart';

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
    final lista = await widget.repositorio.listarClientes();
    if (!mounted) return;
    setState(() {
      _clientes = lista;
      _carregando = false;
    });
  }

  List<Cliente> get _filtrados {
    if (_busca.trim().isEmpty) return _clientes;
    final termo = _busca.toLowerCase();
    return _clientes
        .where((c) => c.nome.toLowerCase().contains(termo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: vinho));
    }

    final clientes = _filtrados;

    return Column(
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
        ),
        Expanded(
          child: clientes.isEmpty
              ? const EstadoVazio(
                  icone: Icons.person_search_outlined,
                  titulo: 'Nenhuma cliente com esse nome',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: clientes.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 10),
                  itemBuilder: (context, indice) {
                    final cliente = clientes[indice];
                    return _CartaoCliente(
                      cliente: cliente,
                      aoTocar: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => FichaClientePage(
                            cliente: cliente,
                            repositorio: widget.repositorio,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CartaoCliente extends StatelessWidget {
  const _CartaoCliente({required this.cliente, required this.aoTocar});

  final Cliente cliente;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
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
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: texto,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cliente.telefone ?? cliente.email,
                      style: const TextStyle(fontSize: 13, color: textoApoio),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: textoApoio),
            ],
          ),
        ),
      ),
    );
  }
}

class FichaClientePage extends StatefulWidget {
  const FichaClientePage({
    super.key,
    required this.cliente,
    required this.repositorio,
  });

  final Cliente cliente;
  final AgendaRepository repositorio;

  @override
  State<FichaClientePage> createState() => _FichaClientePageState();
}

class _FichaClientePageState extends State<FichaClientePage> {
  List<Agendamento> _historico = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final todos = await widget.repositorio.listarAgendamentos();
    if (!mounted) return;
    setState(() {
      _historico =
          todos.where((a) => a.cliente.id == widget.cliente.id).toList()
            ..sort((a, b) => b.inicio.compareTo(a.inicio));
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cliente = widget.cliente;

    return Scaffold(
      appBar: AppBar(title: const Text('Cliente')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              Column(
                children: [
                  AvatarCliente(cliente: cliente, tamanho: 76),
                  const SizedBox(height: 12),
                  Text(cliente.nome, style: estiloTitulo(tamanho: 24)),
                  const SizedBox(height: 4),
                  Text(
                    cliente.email,
                    style: const TextStyle(fontSize: 13.5, color: textoApoio),
                  ),
                  if (cliente.telefone != null)
                    Text(
                      cliente.telefone!,
                      style: const TextStyle(fontSize: 13.5, color: textoApoio),
                    ),
                ],
              ),
              if (cliente.observacao != null) ...[
                const SizedBox(height: 18),
                Container(
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
                          cliente.observacao!,
                          style: const TextStyle(fontSize: 14, color: texto),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 26),
              const Text(
                'HISTÓRICO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: vinho,
                ),
              ),
              const SizedBox(height: 10),
              if (_carregando)
                const Center(child: CircularProgressIndicator(color: vinho))
              else if (_historico.isEmpty)
                const Text(
                  'Nenhum atendimento registrado.',
                  style: TextStyle(fontSize: 14, color: textoApoio),
                )
              else
                ..._historico.map(
                  (agendamento) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: superficie,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: linha),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agendamento.servico.nome,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: texto,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${diaPorExtenso(agendamento.inicio)} · '
                                '${hora(agendamento.inicio)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: textoApoio,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          agendamento.situacao.rotulo,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: textoApoio,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
