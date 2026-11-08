import 'cliente.dart';
import 'servico.dart';

class DadosDoAgendamento {
  DadosDoAgendamento({
    required this.cliente,
    required this.servico,
    required this.inicio,
    required this.duracaoMinutos,
    this.observacao,
  });

  final Cliente cliente;
  final Servico servico;
  final DateTime inicio;
  final int duracaoMinutos;
  final String? observacao;

  DateTime get fim => inicio.add(Duration(minutes: duracaoMinutos));

  // A API recebe só os ids e busca cliente e serviço no banco.
  // O horário vai sem fuso: o back entende como horário de Brasília.
  Map<String, dynamic> toJson() {
    return {
      'client_id': cliente.id,
      'service_id': servico.id,
      'start_time': _semFuso(inicio),
      'duration_minutes': duracaoMinutos,
    };
  }

  static String _semFuso(DateTime data) {
    final iso = data.toIso8601String();
    return iso.endsWith('Z') ? iso.substring(0, iso.length - 1) : iso;
  }
}
