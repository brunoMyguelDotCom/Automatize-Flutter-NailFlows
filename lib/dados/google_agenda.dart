import 'dart:convert';

import 'package:http/http.dart' as http;

import 'agenda_repository_api.dart';
import 'api_config.dart';

class GoogleAgenda {
  GoogleAgenda({String? urlBase, http.Client? cliente})
    : urlBase = urlBase ?? ApiConfig.urlBase,
      _cliente = cliente ?? http.Client();

  final String urlBase;
  final http.Client _cliente;

  // A própria API redireciona para o Google, então o painel só abre o endereço.
  Uri get enderecoDeConexao => Uri.parse('$urlBase/auth/google/connect');

  /// A API só registra as rotas do Google quando roda com
  /// CALENDAR_BACKEND=google. Ainda não existe uma rota que diga se a agenda
  /// já foi conectada, então o painel olha a documentação da API (openapi)
  /// para saber se a integração está ligada.
  Future<bool> integracaoLigada() async {
    final http.Response resposta;
    try {
      resposta = await _cliente
          .get(Uri.parse('$urlBase/openapi.json'))
          .timeout(ApiConfig.tempoDeEspera);
    } catch (_) {
      throw FalhaDaApi('Não consegui falar com o servidor.');
    }

    if (resposta.statusCode != 200) {
      throw FalhaDaApi('A API respondeu ${resposta.statusCode}.');
    }

    final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
    final rotas = corpo is Map ? corpo['paths'] : null;
    return rotas is Map && rotas.containsKey('/auth/google/connect');
  }
}
