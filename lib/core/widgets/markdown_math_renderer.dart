import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

class MarkdownMathRenderer extends StatelessWidget {
  final String content;

  const MarkdownMathRenderer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox();

    // Membagi konten berdasarkan delimiter $$ untuk memisahkan LaTeX dengan teks biasa
    final parts = content.split(r'$$');
    final List<Widget> children = [];

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        // Indeks ganjil: Formula LaTeX Math
        children.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                part.trim(),
                textStyle: const TextStyle(fontSize: 16),
                onErrorFallback: (err) => Text(
                  part, 
                  style: const TextStyle(fontFamily: 'monospace', color: AppColors.error),
                ),
              ),
            ),
          ),
        );
      } else {
        // Indeks genap: Teks biasa (yang mungkin berisi link markdown, tebal, miring)
        children.add(_buildTextAndLinks(part));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildTextAndLinks(String text) {
    final linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(text);

    if (matches.isEmpty) {
      return _buildFormattedText(text);
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        final plainText = text.substring(lastIndex, match.start);
        spans.addAll(_getFormattedSpans(plainText));
      }

      final String label = match.group(1) ?? '';
      final String urlString = match.group(2) ?? '';

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse(urlString);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.launch, size: 10, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final plainText = text.substring(lastIndex);
      spans.addAll(_getFormattedSpans(plainText));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: AppColors.textLightPrimary, height: 1.5),
        children: spans,
      ),
    );
  }

  List<TextSpan> _getFormattedSpans(String text) {
    final List<TextSpan> textSpans = [];
    
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        textSpans.add(TextSpan(
          text: part,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        final subparts = part.split('*');
        for (int j = 0; j < subparts.length; j++) {
          final subpart = subparts[j];
          if (subpart.isEmpty) continue;

          if (j % 2 == 1) {
            textSpans.add(TextSpan(
              text: subpart,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ));
          } else {
            textSpans.add(TextSpan(text: subpart));
          }
        }
      }
    }
    return textSpans;
  }

  Widget _buildFormattedText(String text) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: AppColors.textLightPrimary, height: 1.5),
        children: _getFormattedSpans(text),
      ),
    );
  }
}
