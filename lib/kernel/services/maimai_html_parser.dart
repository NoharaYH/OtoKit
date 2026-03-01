import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class MaimaiHtmlParser {
  static const List<String> levelLabels = [
    "Basic",
    "Advanced",
    "Expert",
    "Master",
    "Re:MASTER",
    "",
    "",
    "",
    "",
    "",
    "U·TA·GE",
  ];

  static const Map<String, int> difficultyLabels = {
    "basic": 0,
    "advanced": 1,
    "expert": 2,
    "master": 3,
    "remaster": 4,
    "utage": 10,
  };

  static List<Map<String, dynamic>> parse(String htmlData) {
    final document = html_parser.parse(htmlData);
    final List<Map<String, dynamic>> records = [];

    // Select all music blocks
    final names = document.querySelectorAll(
      'div.music_name_block.t_l.f_13.break',
    );

    for (var nameNode in names) {
      final title = nameNode.text.trim();

      // Navigate to siblings. In Dart 'html' package, previousElementSibling/nextElementSibling is safer.
      // Based on original logic: nameNode-6 is diff, nameNode-2 is level, nameNode+2 is score, etc.

      // Structure:
      // <img src="...diff_master.png">  [-6 or -8]
      // <div class="music_kind_icon">  [-6 if type exists]
      // <div class="music_level_box">  [-2]
      // <div class="music_name_block"> [TARGET]
      // <div class="music_score_block"> [+2]

      dom.Element? diffNode;
      dom.Element? typeNode;

      // Try offset -6 for diff
      var p1 = nameNode.previousElementSibling; // -1
      var p2 = p1?.previousElementSibling; // -2 (Level)
      var p3 = p2?.previousElementSibling; // -3
      var p4 = p3?.previousElementSibling; // -4
      var p5 = p4?.previousElementSibling; // -5
      var p6 = p5?.previousElementSibling; // -6 (Diff or Type)
      var p7 = p6?.previousElementSibling; // -7
      var p8 = p7?.previousElementSibling; // -8 (Diff if type exists)

      // Look for diff image
      bool isDiff(dom.Element? e) {
        if (e == null || e.localName != 'img') return false;
        final src = e.attributes['src'] ?? '';
        return src.contains('diff_');
      }

      if (isDiff(p6)) {
        diffNode = p6;
      } else if (isDiff(p8)) {
        diffNode = p8;
        typeNode = p6;
      }

      final levelNode = p2;

      var n1 = nameNode.nextElementSibling; // +1
      var scoreNode = n1?.nextElementSibling; // +2
      var n3 = scoreNode?.nextElementSibling; // +3
      var dxScoreNode = n3?.nextElementSibling; // +4
      var n5 = dxScoreNode?.nextElementSibling; // +5
      var fsNode = n5?.nextElementSibling; // +6
      var n7 = fsNode?.nextElementSibling; // +7
      var fcNode = n7?.nextElementSibling; // +8
      var n9 = fcNode?.nextElementSibling; // +9
      var rateNode = n9?.nextElementSibling; // +10

      if (scoreNode == null || scoreNode.localName != 'div') continue;

      final diffSrc = diffNode?.attributes['src'] ?? '';
      final diffMatch = RegExp(r'diff_(.*)\.png').firstMatch(diffSrc);
      final diffLabel = diffMatch?.group(1) ?? '';
      final levelIndex = difficultyLabels[diffLabel] ?? 0;

      final String rate = (rateNode?.attributes['src'] ?? "").contains("_icon_")
          ? RegExp(
                  r'_icon_(.*)\.png',
                ).firstMatch(rateNode!.attributes['src']!)?.group(1) ??
                ""
          : "";

      final String fc = (fcNode?.attributes['src'] ?? "").contains("_icon_")
          ? RegExp(r'_icon_(.*)\.png')
                    .firstMatch(fcNode!.attributes['src']!)
                    ?.group(1)
                    ?.replaceAll("back", "") ??
                ""
          : "";

      final String fs = (fsNode?.attributes['src'] ?? "").contains("_icon_")
          ? RegExp(r'_icon_(.*)\.png')
                    .firstMatch(fsNode!.attributes['src']!)
                    ?.group(1)
                    ?.replaceAll("back", "") ??
                ""
          : "";

      String type = "DX";
      if (typeNode != null) {
        final tSrc = typeNode.attributes['src'] ?? "";
        if (tSrc.contains("music_standard")) {
          type = "SD";
        } else if (typeNode
                .querySelector('img')
                ?.attributes['src']
                ?.contains("music_standard") ==
            true) {
          type = "SD";
        }
      } else {
        // Fallback to parent ID check if possible
        final parentId =
            nameNode.parent?.parent?.parent?.attributes['id'] ?? "";
        if (parentId.startsWith("sta")) type = "SD";
      }

      // Final Utage/DX check
      if (levelIndex == 10) type = "DX";

      records.add({
        "title": title,
        "level": levelNode?.text.trim() ?? "?",
        "level_index": levelIndex,
        "type": type,
        "achievements":
            double.tryParse(scoreNode.text.replaceAll("%", "").trim()) ?? 0.0,
        "dxScore":
            int.tryParse(dxScoreNode?.text.replaceAll(",", "").trim() ?? "0") ??
            0,
        "rate": rate,
        "fc": fc,
        "fs": fs == "fdx" ? "fsd" : (fs == "fdxp" ? "fsdp" : fs),
        "level_label":
            levelLabels[levelIndex == 10
                ? 10
                : (levelIndex > 4 ? 0 : levelIndex)],
      });
    }

    return records;
  }
}
