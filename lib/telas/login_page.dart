import 'package:flutter/material.dart';

import '../dados/acesso.dart';
import '../tema/cores.dart';
import '../tema/tema.dart';
import '../widgets/campo_formulario.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.aoEntrar});

  final VoidCallback aoEntrar;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _mostrarSenha = false;
  bool _entrando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;

    setState(() {
      _entrando = true;
      _erro = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (Acesso.conferir(_email.text, _senha.text)) {
      widget.aoEntrar();
      return;
    }

    setState(() {
      _entrando = false;
      _erro = 'E-mail ou senha incorretos.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: gradienteVinho),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/imagens/logo.png',
                    height: 86,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Painel de agenda',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    decoration: BoxDecoration(
                      color: superficie,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: sombraCartao,
                    ),
                    child: Form(
                      key: _formulario,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Bem-vinda', style: estiloTitulo(tamanho: 24)),
                          const SizedBox(height: 4),
                          const Text(
                            'Entre para ver a agenda do dia.',
                            style: TextStyle(fontSize: 13.5, color: textoApoio),
                          ),
                          const SizedBox(height: 22),
                          CampoFormulario(
                            controlador: _email,
                            rotulo: 'E-mail',
                            dica: 'cris@nailsflow.app',
                            icone: Icons.mail_outline_rounded,
                            teclado: TextInputType.emailAddress,
                            validador: (valor) {
                              final texto = valor?.trim() ?? '';
                              if (texto.isEmpty) return 'Informe o e-mail';
                              if (!texto.contains('@')) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _senha,
                            obscureText: !_mostrarSenha,
                            onFieldSubmitted: (_) => _entrar(),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return 'Informe a senha';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: textoApoio,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _mostrarSenha = !_mostrarSenha,
                                ),
                                icon: Icon(
                                  _mostrarSenha
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: textoApoio,
                                ),
                                tooltip: _mostrarSenha
                                    ? 'Esconder senha'
                                    : 'Mostrar senha',
                              ),
                              filled: true,
                              fillColor: superficie,
                              border: _borda(linha),
                              enabledBorder: _borda(linha),
                              focusedBorder: _borda(vinho),
                              errorBorder: _borda(recusado),
                              focusedErrorBorder: _borda(recusado),
                            ),
                          ),
                          if (_erro != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: recusadoFundo,
                                borderRadius: BorderRadius.circular(12),
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
                                        fontSize: 13.5,
                                        color: recusado,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _entrando ? null : _entrar,
                              style: FilledButton.styleFrom(
                                backgroundColor: vinho,
                              ),
                              child: _entrando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Acesso provisório, enquanto a API não tem autenticação',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _borda(Color cor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor),
    );
  }
}
