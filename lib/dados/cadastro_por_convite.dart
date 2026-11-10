import 'dart:convert';

import 'package:http/http.dart' as http;

import 'agenda_repository_api.dart';
import 'api_config.dart';

/// Link de convite gerado pela API (vale 6 horas e só pode ser usado uma vez).
class ConviteDeCadastro {
  const ConviteDeCadastro({required this.link, required this.expiraEm});

  final String link;
  final DateTime expiraEm;
}

/// Erro do cadastro com o campo que a API apontou ("email" ou "phone"),
/// para o formulário marcar o campo certo.
class FalhaNoCadastro implements Exception {
  FalhaNoCadastro(this.mensagem, {this.campo, this.linkInvalido = false});

  final String mensagem;
  final String? campo;
  final bool linkInvalido;

  @override
  String toString() => mensagem;
}

/// Conversa com as rotas de convite do back (PR #8 do Guilherme):
/// POST /registration-links, GET /registration-links/{token} e
/// POST /registration-links/{token}/register.
class CadastroPorConvite {
  CadastroPorConvite({
    String? urlBase,
    http.Client? cliente,
    String? tokenAdmin,
  }) : urlBase = urlBase ?? ApiConfig.urlBase,
       tokenAdmin = tokenAdmin ?? ApiConfig.tokenAdmin,
       _cliente = cliente ?? http.Client();

  final String urlBase;
  final String tokenAdmin;
  final http.Client _cliente;

  Uri _url(String caminho) => Uri.parse('$urlBase/registration-links$caminho');

  /// Só a profissional gera convites, por isso vai o token de administrador.
  Future<ConviteDeCadastro> gerarLink() async {
    final resposta = await _chamar(
      () => _cliente.post(
        _url(''),
        headers: {
          if (tokenAdmin.isNotEmpty) 'Authorization': 'Bearer $tokenAdmin',
        },
      ),
    );

    if (resposta.statusCode == 401 || resposta.statusCode == 503) {
      throw FalhaDaApi(
        'A API recusou o acesso. Confira o ADMIN_TOKEN usado na compilação '
        'do painel.',
      );
    }
    if (resposta.statusCode != 201) throw FalhaDaApi(_detalhe(resposta));

    final corpo = _json(resposta);
    return ConviteDeCadastro(
      link: corpo['url'] as String,
      expiraEm: DateTime.parse(corpo['expires_at'] as String).toLocal(),
    );
  }

  /// Público: a cliente abre o link sem login.
  Future<void> validar(String token) async {
    final resposta = await _chamar(() => _cliente.get(_url('/$token')));
    if (resposta.statusCode == 410 || resposta.statusCode == 404) {
      throw FalhaNoCadastro(_detalhe(resposta), linkInvalido: true);
    }
    if (resposta.statusCode != 200) {
      throw FalhaNoCadastro(_detalhe(resposta));
    }
  }

  Future<void> cadastrar(
    String token, {
    required String nome,
    required String email,
    required String telefone,
  }) async {
    final resposta = await _chamar(
      () => _cliente.post(
        _url('/$token/register'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({'name': nome, 'email': email, 'phone': telefone}),
      ),
    );

    switch (resposta.statusCode) {
      case 201:
        return;
      case 409:
        // E-mail ou telefone de outra cliente. O convite não é gasto.
        throw FalhaNoCadastro(
          _detalhe(resposta),
          campo: _json(resposta)['field'] as String?,
        );
      case 410:
        throw FalhaNoCadastro(_detalhe(resposta), linkInvalido: true);
      case 422:
        throw FalhaNoCadastro('Confira os dados: algum campo está inválido.');
      default:
        throw FalhaNoCadastro(_detalhe(resposta));
    }
  }

  Future<http.Response> _chamar(
    Future<http.Response> Function() chamada,
  ) async {
    try {
      return await chamada().timeout(const Duration(seconds: 15));
    } catch (_) {
      throw FalhaNoCadastro(
        'Não consegui falar com o servidor. Tente de novo.',
      );
    }
  }

  Map<String, dynamic> _json(http.Response resposta) {
    try {
      final corpo = jsonDecode(utf8.decode(resposta.bodyBytes));
      return corpo is Map<String, dynamic> ? corpo : {};
    } catch (_) {
      return {};
    }
  }

  String _detalhe(http.Response resposta) {
    final detalhe = _json(resposta)['detail'];
    return detalhe is String
        ? detalhe
        : 'O servidor respondeu com erro ${resposta.statusCode}.';
  }
}

/// O link do back é `FRONTEND_URL/cadastro/TOKEN`. Com
/// `FRONTEND_URL=http://painel/#` ele vira `http://painel/#/cadastro/TOKEN`;
/// numa hospedagem que devolve o index para qualquer caminho, fica
/// `http://painel/cadastro/TOKEN`. Aceita os dois jeitos.
String? tokenDoLinkDeCadastro(Uri endereco) {
  const prefixo = '/cadastro/';
  for (final rota in [endereco.fragment, endereco.path]) {
    if (rota.startsWith(prefixo)) {
      final token = rota.substring(prefixo.length).split(RegExp('[/?]')).first;
      if (token.isNotEmpty) return token;
    }
  }
  return null;
}
