import '../modelos/agendamento.dart';
import 'datas.dart';
import 'telefone.dart';

const String nomeDaProfissional = 'Cris Merlos';

const List<String> _diasDaSemana = [
  'segunda',
  'terça',
  'quarta',
  'quinta',
  'sexta',
  'sábado',
  'domingo',
];

/// Texto padrão do lembrete. A profissional pode editar antes de enviar.
String mensagemDeConfirmacao(Agendamento agendamento) {
  final inicio = agendamento.inicio;
  final data =
      '${_doisDigitos(inicio.day)}/${_doisDigitos(inicio.month)}/${inicio.year}';
  final dia = _diasDaSemana[inicio.weekday - 1];

  return '$nomeDaProfissional\n'
      '\n'
      'Oie ${agendamento.cliente.primeiroNome}, este é um lembrete do seu '
      'horário de ${agendamento.servico.nome} em $data ($dia) '
      'às ${hora(inicio)}.\n'
      'Muito obrigada ☺️\n'
      '\n'
      'Pra confirmar, responda:\n'
      '1 - Confirmar\n'
      '2 - Cancelar';
}

/// Número no formato que o WhatsApp entende: só dígitos e com o 55 do Brasil.
/// Devolve null quando o telefone não está completo.
String? numeroParaWhatsapp(String? telefone) {
  if (telefone == null || !telefoneCompleto(telefone)) return null;
  return '55${somenteDigitos(formatarTelefone(telefone))}';
}

/// Abre a conversa com a cliente já com o texto digitado.
Uri linkDoWhatsapp(String numero, String mensagem) {
  return Uri.https('wa.me', '/$numero', {'text': mensagem});
}

String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');
