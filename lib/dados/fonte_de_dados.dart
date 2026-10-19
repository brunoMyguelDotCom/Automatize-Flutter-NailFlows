import 'package:http/http.dart' as http;

import 'agenda_repository.dart';
import 'agenda_repository_api.dart';
import 'agenda_repository_falso.dart';
import 'api_config.dart';

class FonteDeDados {
  FonteDeDados({required this.repositorio, required this.descricao});

  final AgendaRepository repositorio;
  final String descricao;

  bool get ehApi => repositorio is AgendaRepositoryApi;
}

Future<FonteDeDados> escolherFonteDeDados({http.Client? cliente}) async {
  if (!ApiConfig.tentarApi) {
    return FonteDeDados(
      repositorio: AgendaRepositoryFalso(),
      descricao: 'Dados de exemplo (API desligada na compilação)',
    );
  }

  final api = AgendaRepositoryApi(cliente: cliente);

  if (await api.estaNoAr()) {
    return FonteDeDados(
      repositorio: api,
      descricao: 'API em ${ApiConfig.urlBase}',
    );
  }

  return FonteDeDados(
    repositorio: AgendaRepositoryFalso(),
    descricao: 'Dados de exemplo — ${ApiConfig.urlBase} não respondeu',
  );
}
