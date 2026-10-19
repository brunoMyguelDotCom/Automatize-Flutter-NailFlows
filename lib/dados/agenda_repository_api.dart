import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/agendamento.dart';
import '../modelos/cliente.dart';
import '../modelos/servico.dart';
import 'agenda_repository.dart';
import 'agenda_repository_falso.dart';
import 'api_config.dart';

class FalhaDaApi implements Exception {
  FalhaDaApi(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

class AgendaRepositoryApi implements AgendaRepository {
  AgendaRepositoryApi({String? urlBase, http.Client? cliente})
    : urlBase = urlBase ?? ApiConfig.urlBase,
      _cliente = cliente ?? http.Client();

  final String urlBase;
  final http.Client _cliente;

  Uri _url(String caminho, [Map<String, String>? parametros]) {
    return Uri.parse('$urlBase$caminho').replace(queryParameters: parametros);
  }

  Future<bool> estaNoAr() async {
    try {
      final resposta = await _cliente
          .get(_url('/'))
          .timeout(ApiConfig.tempoDeEspera);
      return resposta.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<dynamic> _buscar(Uri url) async {
    final http.Response resposta;
    try {
      resposta = await _cliente.get(url);
    } catch (_) {
      throw FalhaDaApi('Não consegui falar com o servidor.');
    }

    if (resposta.statusCode >= 400) {
      throw FalhaDaApi(_mensagemDoErro(resposta));
    }

    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  String _mensagemDoErro(http.Response resposta) {
    try {
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      final detalhe = corpo is Map ? corpo['detail'] : null;
      if (detalhe is String) return detalhe;
      if (detalhe is Map && detalhe['mensagem'] is String) {
        return detalhe['mensagem'] as String;
      }
      if (detalhe is List && detalhe.isNotEmpty) {
        final primeiro = detalhe.first;
        if (primeiro is Map && primeiro['msg'] is String) {
          return primeiro['msg'] as String;
        }
      }
    } catch (_) {
      // corpo sem JSON: cai na mensagem genérica
    }
    return 'O servidor respondeu com erro ${resposta.statusCode}.';
  }

  @override
  Future<List<Agendamento>> listarAgendamentos({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    final parametros = <String, String>{};
    if (inicio != null) parametros['start_date'] = _semFuso(inicio);
    if (fim != null) parametros['end_date'] = _semFuso(fim);

    final corpo = await _buscar(
      _url('/agendamentos/', parametros.isEmpty ? null : parametros),
    );

    final lista = (corpo as List)
        .map((item) => Agendamento.fromJson(item as Map<String, dynamic>))
        .toList();
    lista.sort((a, b) => a.inicio.compareTo(b.inicio));
    return lista;
  }

  @override
  Future<List<Cliente>> listarClientes() async {
    final corpo = await _buscar(_url('/clientes/'));

    final lista = (corpo as List)
        .map((item) => Cliente.fromJson(item as Map<String, dynamic>))
        .toList();
    lista.sort((a, b) => a.nome.compareTo(b.nome));
    return lista;
  }

  @override
  Future<List<Servico>> listarServicos() async {
    return AgendaRepositoryFalso.catalogo;
  }

  @override
  Future<Cliente> criarCliente(Cliente cliente) async {
    final corpo = await _enviar(
      'POST',
      _url('/clientes/'),
      _corpoDoCliente(cliente),
    );
    return Cliente.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<Cliente> atualizarCliente(String id, Cliente cliente) async {
    final corpo = await _enviar(
      'PATCH',
      _url('/clientes/$id'),
      _corpoDoCliente(cliente),
    );
    return Cliente.fromJson(corpo as Map<String, dynamic>);
  }

  @override
  Future<void> excluirCliente(String id) async {
    await _enviar('DELETE', _url('/clientes/$id'), null);
  }

  Map<String, dynamic> _corpoDoCliente(Cliente cliente) {
    return {
      'name': cliente.nome,
      'email': cliente.email,
      'phone': cliente.telefone,
    };
  }

  Future<dynamic> _enviar(
    String metodo,
    Uri url,
    Map<String, dynamic>? corpo,
  ) async {
    final requisicao = http.Request(metodo, url);
    requisicao.headers['Content-Type'] = 'application/json; charset=utf-8';
    if (corpo != null) requisicao.body = jsonEncode(corpo);

    final http.Response resposta;
    try {
      resposta = await http.Response.fromStream(
        await _cliente.send(requisicao),
      );
    } catch (_) {
      throw FalhaDaApi('Não consegui falar com o servidor.');
    }

    if (resposta.statusCode >= 400) {
      throw FalhaDaApi(_mensagemDoErro(resposta));
    }

    if (resposta.body.isEmpty) return null;
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  String _semFuso(DateTime data) {
    final iso = data.toIso8601String();
    return iso.endsWith('Z') ? iso.substring(0, iso.length - 1) : iso;
  }
}
