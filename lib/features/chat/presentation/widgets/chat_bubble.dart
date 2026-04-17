import 'package:flutter/material.dart';

import '../../../../core/models/chat_message.dart';
import 'grammar_feedback_card.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showGrammarFeedback = false;

  bool get _isUser => widget.message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: _isUser ? 56 : 16,
        right: _isUser ? 16 : 56,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              _isUser ? 'You' : 'AI Tutor',
              style: textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _isUser
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(_isUser ? 20 : 4),
                bottomRight: Radius.circular(_isUser ? 4 : 20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.content,
                  style: textTheme.bodyLarge?.copyWith(
                    color: _isUser
                        ? colorScheme.onSurface
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
                if (!_isUser || widget.message.grammarFeedback != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isUser)
                          _ActionChip(
                            icon: Icons.volume_up_rounded,
                            label: 'Play',
                            onTap: () {},
                            colorScheme: colorScheme,
                          ),
                        if (_isUser && widget.message.grammarFeedback != null)
                          _ActionChip(
                            icon: _showGrammarFeedback
                                ? Icons.expand_less_rounded
                                : Icons.spellcheck_rounded,
                            label: _showGrammarFeedback ? 'Hide' : 'Grammar Tip',
                            onTap: () => setState(
                              () => _showGrammarFeedback = !_showGrammarFeedback,
                            ),
                            colorScheme: colorScheme,
                            highlight: true,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_showGrammarFeedback && widget.message.grammarFeedback != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GrammarFeedbackCard(feedback: widget.message.grammarFeedback!),
            ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool highlight;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: highlight
                ? colorScheme.tertiaryContainer
                : colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: highlight
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: highlight
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
