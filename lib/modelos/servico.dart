class Servico {
  Servico({
    required this.id,
    required this.nome,
    required this.duracaoMinutos,
    this.ativo = true,
  });

  final String id;
  final String nome;
  final int duracaoMinutos;
  final bool ativo;

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'] as String,
      nome: json['name'] as String,
      duracaoMinutos: json['duration_minutes'] as int,
      ativo: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'duration_minutes': duracaoMinutos,
      'active': ativo,
    };
  }
}
