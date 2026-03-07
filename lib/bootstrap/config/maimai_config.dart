class MaimaiConfig {
  static const String lxnsUploadPath = "user/maimai/player/html";
  static const String lxnsPlayerPath = "user/maimai/player";

  static const String dfUploadPath =
      "maimaidxprober/player/update_records_html";
  static const String wahlapBase = "https://maimai.wahlap.com/maimai-mobile/";
  static const String wahlapAuthLabel = "maimai-dx";

  // 乐曲分类 ID 列表 (用于细分爬取)
  static const List<String> genreList = [
    "101",
    "102",
    "103",
    "104",
    "105",
    "106",
  ];
}
