class Servico {
  Servico({
    required this.id,
    required this.nome,
    required this.duracaoMinutos,
    this.preco,
    this.ativo = true,
  });

  final String id;
  final String nome;
  final int duracaoMinutos;
  final double? preco;
  final bool ativo;

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'] as String,
      nome: json['name'] as String,
      duracaoMinutos: json['duration_minutes'] as int,
      preco: (json['price'] as num?)?.toDouble(),
      ativo: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'duration_minutes': duracaoMinutos,
      'price': preco,
      'active': ativo,
    };
  }
}
