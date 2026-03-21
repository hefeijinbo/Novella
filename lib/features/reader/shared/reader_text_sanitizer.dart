import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

String sanitizeReaderHtmlTextNodes(String html, Set<int> invisibleCodepoints) {
  if (html.isEmpty) {
    return html;
  }

  try {
    final fragment = html_parser.parseFragment(html);
    var changed = false;

    void visit(dom.Node node) {
      if (node is dom.Text) {
        final sanitized = sanitizeReaderTextNode(
          node.text,
          invisibleCodepoints,
        );
        if (sanitized != node.text) {
          node.text = sanitized;
          changed = true;
        }
        return;
      }

      for (final child in node.nodes) {
        visit(child);
      }
    }

    for (final node in fragment.nodes) {
      visit(node);
    }

    return changed ? _serializeFragmentNodes(fragment.nodes) : html;
  } catch (_) {
    return sanitizeReaderTextNode(html, invisibleCodepoints);
  }
}

String sanitizeReaderTextNode(String text, Set<int> invisibleCodepoints) {
  if (text.isEmpty) {
    return text;
  }

  final buffer = StringBuffer();
  var changed = false;
  var previousWasZeroWidthSpace = false;

  for (final rune in text.runes) {
    if (invisibleCodepoints.contains(rune)) {
      changed = true;
      continue;
    }

    if (rune == 0x200B) {
      if (previousWasZeroWidthSpace) {
        changed = true;
        continue;
      }
      previousWasZeroWidthSpace = true;
    } else {
      previousWasZeroWidthSpace = false;
    }

    buffer.writeCharCode(rune);
  }

  return changed ? buffer.toString() : text;
}

String normalizeReaderText(String text) {
  return text
      .replaceAll('\u200B', '')
      .replaceAll('\u00A0', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _serializeFragmentNodes(List<dom.Node> nodes) {
  final buffer = StringBuffer();
  for (final node in nodes) {
    if (node is dom.Element) {
      buffer.write(node.outerHtml);
    } else if (node is dom.Text) {
      buffer.write(node.text);
    }
  }
  return buffer.toString();
}
