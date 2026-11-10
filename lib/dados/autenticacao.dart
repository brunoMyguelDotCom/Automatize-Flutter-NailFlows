import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de login já em português, pronto para mostrar na tela.
class FalhaNoLogin implements Exception {
  FalhaNoLogin(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// O painel fala com esta interface, e não direto com o Supabase. Assim os
/// testes trocam por uma versão falsa sem precisar de internet.
abstract class Autenticacao {
  bool get logado;

  /// Avisa sempre que a sessão muda: login, logout ou sessão restaurada
  /// quando a página é aberta de novo.
  Stream<bool> get mudancas;

  Future<void> entrar(String email, String senha);

  Future<void> sair();
}

/// Login com o usuário criado no Supabase Auth do projeto.
class AutenticacaoSupabase implements Autenticacao {
  AutenticacaoSupabase([SupabaseClient? cliente])
    : _cliente = cliente ?? Supabase.instance.client;

  final SupabaseClient _cliente;

  @override
  bool get logado => _cliente.auth.currentSession != null;

  @override
  Stream<bool> get mudancas =>
      _cliente.auth.onAuthStateChange.map((estado) => estado.session != null);

  @override
  Future<void> entrar(String email, String senha) async {
    try {
      await _cliente.auth.signInWithPassword(
        email: email.trim(),
        password: senha,
      );
    } on AuthException catch (erro) {
      throw FalhaNoLogin(traduzirErroDoLogin(erro.message));
    } catch (_) {
      throw FalhaNoLogin('Não consegui falar com o servidor. Tente de novo.');
    }
  }

  @override
  Future<void> sair() => _cliente.auth.signOut();
}

/// O Supabase responde em inglês; a tela mostra em português.
String traduzirErroDoLogin(String mensagem) {
  final texto = mensagem.toLowerCase();
  if (texto.contains('invalid login credentials')) {
    return 'E-mail ou senha incorretos.';
  }
  if (texto.contains('email not confirmed')) {
    return 'Esse e-mail ainda não foi confirmado no Supabase.';
  }
  if (texto.contains('rate limit') || texto.contains('too many')) {
    return 'Muitas tentativas. Espere um pouco e tente de novo.';
  }
  return 'Não foi possível entrar: $mensagem';
}
