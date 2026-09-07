class AppStrings {
  AppStrings._();

  static const appTitle = 'Climinha';
  static const emptyCityList = 'Nenhuma cidade cadastrada ainda.';
  static const addCityDialogTitle = 'Adicionar cidade';
  static const addCityHint = 'Ex: São Paulo';
  static const cancel = 'Cancelar';
  static const add = 'Adicionar';
  static const cityAlreadyRegistered = 'Essa cidade já está cadastrada.';
  static const historyTooltip = 'Histórico de 1 ano atrás';
  static const historyRequiresPaidPlan =
      'Histórico indisponível: esse recurso pode exigir um plano pago da WeatherAPI.';

  static String historyTitle(String cityName) => 'Histórico · $cityName';
  static String cityNotFound(String cityName) => 'Cidade não encontrada: $cityName';
  static String errorFetchingWeather(int statusCode) => 'Erro ao buscar clima (status $statusCode)';
  static String errorFetchingCity(int statusCode) => 'Erro ao buscar cidade (status $statusCode)';
  static String errorFetchingForecast(int statusCode) => 'Erro ao buscar previsão (status $statusCode)';
  static String errorFetchingHistory(int statusCode) => 'Erro ao buscar histórico (status $statusCode)';

}
