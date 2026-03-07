import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';

import '../../domain/services/html_record_parser.dart';

@lazySingleton
class MaimaiHtmlParserImpl implements HtmlRecordParser {
  static const List<String> _levelLabels = [
    'Basic',
    'Advanced',
    'Expert',
    'Master',
    'Re:MASTER',
    '',
    '',
    '',
    '',
    '',
    'U·TA·GE',
  ];

  static const Map<String, int> _difficultyLabels = {
    'basic': 0,
    'advanced': 1,
    'expert': 2,
    'master': 3,
    'remaster': 4,
    'utage': 10,
  };

  @override
  List<Map<String, dynamic>> parse(String html) {
    final document = html_parser.parse(html);
    final List<Map<String, dynamic>> records = [];

    final names = document.querySelectorAll(
      'div.music_name_block.t_l.f_13.break',
    );

    for (var nameNode in names) {
      final title = nameNode.text.trim();

      dom.Element? diffNode;
      dom.Element? typeNode;

      var p1 = nameNode.previousElementSibling;
      var p2 = p1?.previousElementSibling;
      var p3 = p2?.previousElementSibling;
      var p4 = p3?.previousElementSibling;
      var p5 = p4?.previousElementSibling;
      var p6 = p5?.previousElementSibling;
      var p7 = p6?.previousElementSibling;
      var p8 = p7?.previousElementSibling;

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

      var n1 = nameNode.nextElementSibling;
      var scoreNode = n1?.nextElementSibling;
      var n3 = scoreNode?.nextElementSibling;
      var dxScoreNode = n3?.nextElementSibling;
      var n5 = dxScoreNode?.nextElementSibling;
      var fsNode = n5?.nextElementSibling;
      var n7 = fsNode?.nextElementSibling;
      var fcNode = n7?.nextElementSibling;
      var n9 = fcNode?.nextElementSibling;
      var rateNode = n9?.nextElementSibling;

      if (scoreNode == null || scoreNode.localName != 'div') continue;

      final diffSrc = diffNode?.attributes['src'] ?? '';
      final diffMatch = RegExp(r'diff_(.*)\.png').firstMatch(diffSrc);
      final diffLabel = diffMatch?.group(1) ?? '';
      final levelIndex = _difficultyLabels[diffLabel] ?? 0;

      final String rate = (rateNode?.attributes['src'] ?? '').contains('_icon_')
          ? RegExp(r'_icon_(.*)\.png')
                  .firstMatch(rateNode!.attributes['src']!)?.group(1) ??
              ''
          : '';

      final String fc = (fcNode?.attributes['src'] ?? '').contains('_icon_')
          ? RegExp(r'_icon_(.*)\.png')
                    .firstMatch(fcNode!.attributes['src']!)
                    ?.group(1)
                    ?.replaceAll('back', '') ??
                ''
          : '';

      final String fs = (fsNode?.attributes['src'] ?? '').contains('_icon_')
          ? RegExp(r'_icon_(.*)\.png')
                    .firstMatch(fsNode!.attributes['src']!)
                    ?.group(1)
                    ?.replaceAll('back', '') ??
                ''
          : '';

      String type = 'DX';
      if (typeNode != null) {
        final tSrc = typeNode.attributes['src'] ?? '';
        if (tSrc.contains('music_standard')) {
          type = 'SD';
        } else if (typeNode
                .querySelector('img')
                ?.attributes['src']
                ?.contains('music_standard') ==
            true) {
          type = 'SD';
        }
      } else {
        final parentId =
            nameNode.parent?.parent?.parent?.attributes['id'] ?? '';
        if (parentId.startsWith('sta')) type = 'SD';
      }

      if (levelIndex == 10) type = 'DX';

      records.add({
        'title': title,
        'level': levelNode?.text.trim() ?? '?',
        'level_index': levelIndex,
        'type': type,
        'achievements':
            double.tryParse(scoreNode.text.replaceAll('%', '').trim()) ?? 0.0,
        'dxScore':
            int.tryParse(dxScoreNode?.text.replaceAll(',', '').trim() ?? '0') ??
                0,
        'rate': rate,
        'fc': fc,
        'fs': fs == 'fdx' ? 'fsd' : (fs == 'fdxp' ? 'fsdp' : fs),
        'level_label': _levelLabels[
            levelIndex == 10 ? 10 : (levelIndex > 4 ? 0 : levelIndex)],
      });
    }

    return records;
  }
}
