# Previu

Aplicativo de monitoramento de clima feito em Flutter. Permite cadastrar cidades, ver o clima atual, a previsão de 7 dias, o histórico de 1 ano atrás e o clima da localização atual do dispositivo.

## Stack

- **Flutter** / Dart
- **Riverpod** (`flutter_riverpod`) para gerenciamento de estado e injeção de dependência
- **WeatherAPI** ([weatherapi.com](https://www.weatherapi.com/)) como fonte de dados
- **envied** para ofuscar a chave de API em tempo de compilação 
- **shared_preferences** para persistir localmente as cidades cadastradas
- **geolocator** para a geolocalização do dispositivo
- **GitHub Actions** para CI (`flutter analyze` + `flutter test` a cada push/PR)

## Como rodar

1. Instale as dependências:

   ```bash
   flutter pub get
   ```

2. Crie um arquivo `.env` na raiz do projeto com sua chave da [WeatherAPI](https://www.weatherapi.com/) (tem plano gratuito):

   ```
   WEATHER_API_KEY=sua_chave_aqui
   ```

3. Gere o código do `envied` (lê o `.env` e gera `lib/env/env.g.dart`):

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Rode o app:

   ```bash
   flutter run
   ```

Para rodar a checagem estática e os testes (o mesmo que o CI roda):

```bash
flutter analyze
flutter test
```

## Arquitetura

Segue o padrão **MVVM** descrito no guia oficial do Flutter ([docs.flutter.dev/app-architecture](https://docs.flutter.dev/app-architecture/concepts)), com camadas em uma via só de dependência:

```
View (screens/)
  → ViewModel (view_models/, providers Riverpod)
    → Repository (repositories/, cache com TTL de 5 min)
      → Service (services/, chamadas HTTP puras)
        → Model (models/)
```

- **View**: nunca acessa `services/` ou `repositories/` diretamente, só providers expostos pela ViewModel.
- **ViewModel**: contém a lógica de apresentação e traduz erros/estados brutos em algo pronto para a UI (ex: `describeLocationCardError`).
- **Repository**: cache em memória com TTL, para não repetir requisição em toda troca de tela.
- **Service**: só sabe conversar com a WeatherAPI; erros de rede viram `WeatherApiException`.

Testes: modelos, repositório, view models e widgets, usando fakes escritos à mão (implementações simples das interfaces/classes reais) em vez de biblioteca de mock.

## Requisitos funcionais

- [x] Cadastro e listagem de cidades (adicionar, remover, sem duplicidade — comparação por coordenadas, não por nome, para lidar com cidades homônimas)
- [x] Persistência local das cidades cadastradas
- [x] Clima atual
- [x] Previsão de 7 dias
- [x] Histórico do mesmo dia, 1 ano atrás
- [x] Testes automatizados

## Diferenciais implementados

- [x] Arquitetura escalável e desacoplada (MVVM completo)
- [x] Injeção de dependência (Riverpod)
- [x] CI/CD (GitHub Actions)
- [x] Pull-to-refresh
- [x] Cache inteligente das requisições (TTL de 5 min)
- [x] Testes instrumentados/UI (widget tests)
- [x] Geolocalização automática (clima da localização atual)
- [x] Dark mode (segue o tema do sistema)

## Melhorias futuras

- Persistir o cache em disco (`shared_preferences`) para um modo offline mais completo (hoje o cache é só em memória, some ao fechar o app)
- Extrair `CityListScreen` (hoje concentra vários widgets grandes) em componentes menores dentro de `widgets/`
- Introduzir uma abstração (`abstract class`) para `WeatherRepository`, e injetar `http.Client` em `WeatherService`, facilitando testes unitários mais isolados
- Tratar erros de parse (`FormatException`) e timeout separadamente do erro genérico de rede em `WeatherService`
- Alternância manual de tema (hoje só segue o tema do sistema)
