class Cliente {
  Cliente({
    required this.nome,
    required this.email,
    this.id,
    this.telefone,
    this.observacao,
  });

  final String? id;
  final String nome;
  final String email;
  final String? telefone;
  final String? observacao;

  String get primeiroNome => nome.split(' ').first;

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as String?,
      nome: json['name'] as String,
      email: json['email'] as String,
      telefone: json['phone'] as String?,
      observacao: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'phone': telefone,
      'notes': observacao,
    };
  }
}
