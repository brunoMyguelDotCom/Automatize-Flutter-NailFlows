import 'cliente.dart';
import 'servico.dart';

enum StatusConvite {
  pendente,
  confirmado,
  recusado,
  talvez;

  static StatusConvite fromJson(String? valor) {
    switch (valor) {
      case 'Confirmed':
        return StatusConvite.confirmado;
      case 'Refused':
        return StatusConvite.recusado;
      case 'Maybe':
        return StatusConvite.talvez;
      default:
        return StatusConvite.pendente;
    }
  }

  String get json {
    switch (this) {
      case StatusConvite.confirmado:
        return 'Confirmed';
      case StatusConvite.recusado:
        return 'Refused';
      case StatusConvite.talvez:
        return 'Maybe';
      case StatusConvite.pendente:
        return 'Pending';
    }
  }

  String get rotulo {
    switch (this) {
      case StatusConvite.confirmado:
        return 'Confirmado';
      case StatusConvite.recusado:
        return 'Recusado';
      case StatusConvite.talvez:
        return 'Talvez';
      case StatusConvite.pendente:
        return 'Pendente';
    }
  }
}

enum SituacaoAtendimento {
  agendado,
  concluido,
  cancelado,
  faltou;

  static SituacaoAtendimento fromJson(String? valor) {
    switch (valor) {
      case 'Done':
        return SituacaoAtendimento.concluido;
      case 'Canceled':
        return SituacaoAtendimento.cancelado;
      case 'NoShow':
        return SituacaoAtendimento.faltou;
      default:
        return SituacaoAtendimento.agendado;
    }
  }

  String get json {
    switch (this) {
      case SituacaoAtendimento.concluido:
        return 'Done';
      case SituacaoAtendimento.cancelado:
        return 'Canceled';
      case SituacaoAtendimento.faltou:
        return 'NoShow';
      case SituacaoAtendimento.agendado:
        return 'Scheduled';
    }
  }

  String get rotulo {
    switch (this) {
      case SituacaoAtendimento.concluido:
        return 'Concluído';
      case SituacaoAtendimento.cancelado:
        return 'Cancelado';
      case SituacaoAtendimento.faltou:
        return 'Faltou';
      case SituacaoAtendimento.agendado:
        return 'Agendado';
    }
  }
}

class Agendamento {
  Agendamento({
    required this.id,
    required this.cliente,
    required this.servico,
    required this.inicio,
    required this.duracaoMinutos,
    this.preco,
    this.observacao,
    this.situacao = SituacaoAtendimento.agendado,
    this.statusConvite = StatusConvite.pendente,
    this.googleEventId,
    this.ultimaSincronizacao,
  });

  final String id;
  final Cliente cliente;
  final Servico servico;
  final DateTime inicio;
  final int duracaoMinutos;
  final double? preco;
  final String? observacao;
  final SituacaoAtendimento situacao;
  final StatusConvite statusConvite;
  final String? googleEventId;
  final DateTime? ultimaSincronizacao;

  DateTime get fim => inicio.add(Duration(minutes: duracaoMinutos));

  bool get ativo => situacao == SituacaoAtendimento.agendado;

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    final sync = json['sync_state'] as Map<String, dynamic>? ?? const {};

    return Agendamento(
      id: json['id'] as String,
      cliente: Cliente.fromJson(json['client'] as Map<String, dynamic>),
      servico: Servico.fromJson(json['service'] as Map<String, dynamic>),
      inicio: DateTime.parse(json['start_time'] as String),
      duracaoMinutos: json['duration_minutes'] as int,
      preco: (json['price'] as num?)?.toDouble(),
      observacao: json['notes'] as String?,
      situacao: SituacaoAtendimento.fromJson(
        json['appointment_status'] as String?,
      ),
      statusConvite: StatusConvite.fromJson(sync['status'] as String?),
      googleEventId: sync['google_event_id'] as String?,
      ultimaSincronizacao: sync['last_synced'] == null
          ? null
          : DateTime.parse(sync['last_synced'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': cliente.toJson(),
      'service': servico.toJson(),
      'start_time': inicio.toIso8601String(),
      'end_time': fim.toIso8601String(),
      'duration_minutes': duracaoMinutos,
      'price': preco,
      'notes': observacao,
      'appointment_status': situacao.json,
      'sync_state': {
        'google_event_id': googleEventId,
        'status': statusConvite.json,
        'last_synced': ultimaSincronizacao?.toIso8601String(),
      },
    };
  }
}
