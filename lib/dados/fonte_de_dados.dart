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

/// A API publicada não respondeu nem depois de esperar ela acordar.
class ServidorForaDoAr implements Exception {
  @override
  String toString() =>
      'O servidor não respondeu. Confira a internet e tente de novo.';
}

Future<FonteDeDados> escolherFonteDeDados({
  http.Client? cliente,
  bool? publicada,
}) async {
  if (!ApiConfig.tentarApi) {
    return FonteDeDados(
      repositorio: AgendaRepositoryFalso(),
      descricao: 'Dados de exemplo (API desligada na compilação)',
    );
  }

  final api = AgendaRepositoryApi(cliente: cliente);

  // No site publicado, cair nos dados de exemplo mostraria uma agenda falsa
  // para a Cris. Então espera a API acordar e, se mesmo assim falhar, avisa.
  if (publicada ?? ApiConfig.publicada) {
    if (await api.estaNoAr(espera: ApiConfig.esperaParaAcordar)) {
      return FonteDeDados(
        repositorio: api,
        descricao: 'API em ${ApiConfig.urlBase}',
      );
    }
    throw ServidorForaDoAr();
  }

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
