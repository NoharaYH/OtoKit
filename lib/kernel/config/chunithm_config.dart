class ChunithmConfig {
  static const String lxnsUploadPath = "user/chunithm/player/html";
  static const String lxnsPlayerPath = "user/chunithm/player";

  static const String dfUploadPath =
      "chunithmprober/player/update_records_html";
  static const String wahlapBase = "https://chunithm.wahlap.com/mobile/";
  static const String wahlapAuthLabel = "chunithm";

  // 中二节奏默认不按类型细分（由 URL 中的难度参数直接拆分数据量）
  static const List<String> genreList = [];
}
