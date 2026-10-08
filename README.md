# NailsFlow — painel de agenda

Front-end do projeto Automatize, feito em Flutter. É o painel onde a nail designer
organiza os atendimentos: ver a agenda do dia, acompanhar quem confirmou o horário
e manter clientes e serviços.

O alvo principal é o **acesso pelo navegador**. O mesmo código gera o aplicativo
Android depois, sem reescrever telas.

> **Estado atual:** o painel já roda com dados de exemplo em memória. A ligação com
> a API ainda não foi feita — veja [Ligação com a API](#ligação-com-a-api).

## Como rodar

Pré-requisitos: [Flutter](https://docs.flutter.dev/get-started/install) 3.x e o
Chrome instalado.

```bash
git clone https://github.com/brunoMyguelDotCom/Automatize-Flutter-NailFlows.git
cd Automatize-Flutter-NailFlows
flutter pub get
flutter run -d chrome
```

Para gerar a versão publicável:

```bash
flutter build web
```

Os arquivos saem em `build/web/` e podem ser servidos por qualquer hospedagem
estática.

Antes de cada commit:

```bash
dart format lib test
flutter analyze
flutter test
```

## Estrutura

```
lib/
├── main.dart              liga o app e escolhe de onde vêm os dados
├── tema/
│   ├── cores.dart         a paleta da marca
│   └── tema.dart          tema do Material e o estilo dos títulos
├── modelos/               as classes do domínio e a conversão de JSON
│   ├── agendamento.dart
│   ├── cliente.dart
│   └── servico.dart
├── dados/
│   ├── agenda_repository.dart        o contrato: o que o app pede
│   └── agenda_repository_falso.dart  dados de exemplo em memória
├── telas/
│   └── agenda_page.dart   a agenda do dia
├── widgets/               peças reaproveitadas pelas telas
└── util/
    └── datas.dart         formatação de data e hora em português
```

## Regras do domínio

- Um atendimento ocupa da hora de início até o fim, calculado pela **duração do
  serviço**. Não existe atendimento sem serviço definido.
- **Dois atendimentos não podem se sobrepor.** A verificação compara início e fim,
  não apenas o horário de começo.
- O **status do convite** é a resposta da cliente e vem do Google Agenda:
  `pendente`, `confirmado`, `recusado` ou `talvez`.
- A **situação do atendimento** é decidida pela profissional: `agendado`,
  `concluído`, `cancelado` ou `faltou`. São coisas diferentes — uma cliente pode
  ter confirmado e faltado.
- **Cancelar não apaga.** O atendimento continua na agenda, marcado como cancelado.
- Datas e horas trafegam em ISO 8601 com fuso, no formato
  `2026-10-20T14:00:00-03:00`.

## Ligação com a API

A API fica em
[Automatize-Python-NailFlows](https://github.com/brunoMyguelDotCom/Automatize-Python-NailFlows).

Todo acesso a dados passa pela interface `AgendaRepository`. Hoje existe uma
implementação em memória, `AgendaRepositoryFalso`, com uma semana de exemplo. A
implementação que chama a API entra como uma segunda classe, e a troca acontece em
uma linha do `main.dart`:

```dart
final AgendaRepository repositorio = AgendaRepositoryFalso();
```

Nenhuma tela precisa mudar nessa troca.

Como o painel roda no navegador, a API precisa liberar **CORS** para o endereço
onde ele for publicado, senão o navegador bloqueia as chamadas.

## Identidade visual

Paleta e tipografia vêm do site da profissional, para app e site terem a mesma cara.
As cores estão em `lib/tema/cores.dart`.

As fontes Playfair Display e Montserrat são carregadas pelo `web/index.html`. Ao
empacotar para Android, elas precisarão ser incluídas como assets do projeto.
