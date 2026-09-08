class AppStrings {
  AppStrings._();

  static const appTitle = 'Previu';
  static const emptyCityList = 'Nenhuma cidade cadastrada ainda.';
  static const addCityDialogTitle = 'Adicionar cidade';
  static const addCityHint = 'Ex: São Paulo';
  static const cancel = 'Cancelar';
  static const add = 'Adicionar';
  static const cityAlreadyRegistered = 'Essa cidade já está cadastrada.';
  static const historyTooltip = 'Histórico de 1 ano atrás';
  static const historyRequiresPaidPlan =
      'Histórico indisponível: esse recurso pode exigir um plano pago da WeatherAPI.';
  static const emptyCityName = 'Digite o nome de uma cidade.';
  static const networkError = 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
  static const useMyLocation = 'Usar minha localização';
  static const locationServiceDisabled =
      'Ative o serviço de localização do dispositivo para usar essa função.';
  static const locationPermissionDenied = 'Permissão de localização negada.';
  static const locationPermissionDeniedForever =
      'Permissão de localização negada permanentemente. Habilite nas configurações do dispositivo.';
  static const locationTimeout =
      'Não foi possível obter sua localização a tempo. Toque para tentar novamente.';
  static const locatingMessage = 'Buscando sua localização...';
  static const currentLocationLabel = 'Sua localização atual';
  static const enableLocationPrompt = 'Toque para tentar novamente';
  static const openSettings = 'Abrir configurações';
  static const listHint = 'Toque em uma cidade para ver detalhes · arraste para remover';
  static const staleDataWarning = 'Sem conexão — mostrando o último dado disponível';
  static const undo = 'Desfazer';

  static String historyTitle(String cityName) => 'Histórico · $cityName';
  static String cityNotFound(String cityName) => 'Cidade não encontrada: $cityName';
  static String errorFetchingWeather(int statusCode) => 'Erro ao buscar clima (status $statusCode)';
  static String errorFetchingCity(int statusCode) => 'Erro ao buscar cidade (status $statusCode)';
  static String errorFetchingForecast(int statusCode) => 'Erro ao buscar previsão (status $statusCode)';
  static String errorFetchingHistory(int statusCode) => 'Erro ao buscar histórico (status $statusCode)';
  static String cityRemoved(String cityName) => '$cityName removida';

}
