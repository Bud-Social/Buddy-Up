import 'package:flutter/material.dart';
import '../../../data/models/post.dart';
import '../../../core/theme/app_theme.dart';

/// Poll voting UI. Single-choice polls vote instantly (radio semantics);
/// multi-choice polls accumulate a pending selection with checkboxes and
/// submit via a Vote button once the min/max rules are satisfied.
class PollWidget extends StatefulWidget {
  final Poll poll;
  final String? postId;
  final void Function(String postId, List<String> optionIds)? onVote;

  const PollWidget({
    super.key,
    required this.poll,
    this.postId,
    this.onVote,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  final Set<String> _pending = <String>{};
  bool _submitting = false;

  int get _minSel => widget.poll.minSelections < 1 ? 1 : widget.poll.minSelections;
  int get _maxSel {
    final raw = widget.poll.maxSelections;
    final floor = widget.poll.allowMultiple ? 2 : 1;
    return raw < floor ? floor : raw;
  }

  bool get _hasVoted => widget.poll.userVotedOptionIds.isNotEmpty;
  bool get _canReceiveVotes => !_hasVoted && !widget.poll.isClosed && widget.postId != null;
  bool get _selectionValid => _pending.length >= _minSel && _pending.length <= _maxSel;

  void _toggle(String optionId) {
    if (!_canReceiveVotes) return;
    setState(() {
      if (_pending.contains(optionId)) {
        _pending.remove(optionId);
      } else if (_pending.length < _maxSel) {
        _pending.add(optionId);
      }
    });
  }

  Future<void> _submit() async {
    if (!_selectionValid || _submitting) return;
    setState(() => _submitting = true);
    try {
      widget.onVote?.call(widget.postId!, _pending.toList());
      // Optimistically clear; parent replaces the poll object on success.
      if (mounted) setState(() => _pending.clear());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes = widget.poll.totalVotes;
    final isClosed = widget.poll.isClosed;
    final hasVoted = _hasVoted;
    final isMulti = widget.poll.allowMultiple;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.poll.question,
            style: const TextStyle(
              color: BuddyColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isMulti && _canReceiveVotes)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _minSel == _maxSel
                    ? 'Select $_minSel option${_minSel == 1 ? '' : 's'}'
                    : 'Select $_minSel–$_maxSel options',
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          ...widget.poll.options.map((option) {
            final voted = widget.poll.userVotedOptionIds.contains(option.id);
            final pending = _pending.contains(option.id);
            final atMax = isMulti && !pending && _pending.length >= _maxSel;
            final enabled = isClosed || hasVoted
                ? false
                : !(isMulti && atMax);
            return _PollOptionBar(
              option: option.copyWith(userVoted: voted || pending),
              totalVotes: totalVotes,
              // Results view only after voting/closure.
              showResults: isClosed || hasVoted,
              leadingIcon: isMulti ? Icons.check_box : Icons.radio_button_unchecked,
              checked: voted || pending,
              onTap: enabled ? () => isMulti ? _toggle(option.id) : widget.onVote?.call(widget.postId!, [option.id]) : null,
            );
          }),
          if (isMulti && _canReceiveVotes) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                ),
                onPressed: _selectionValid ? _submit : null,
                child: _submitting
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_pending.isEmpty ? 'Vote' : 'Vote ($_pending)'),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '${_formatCount(totalVotes)} votes${isClosed ? ' · Closed' : ''}',
            style: const TextStyle(
              color: BuddyColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}m';
  }
}

class _PollOptionBar extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool showResults;
  final IconData leadingIcon;
  final bool checked;
  final VoidCallback? onTap;

  const _PollOptionBar({
    required this.option,
    required this.totalVotes,
    required this.showResults,
    required this.leadingIcon,
    required this.checked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes > 0 ? (option.voteCount / totalVotes) * 100 : 0.0;
    final isSelected = option.userVoted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Stack(
            children: [
              if (showResults || isSelected)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: (percentage / 100) * MediaQuery.of(context).size.width * 0.85,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BuddyColors.green.withValues(alpha: 0.2)
                              : BuddyColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      checked ? Icons.check_box_outlined : leadingIcon,
                      size: 18,
                      color: checked ? BuddyColors.green : BuddyColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          color: BuddyColors.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (showResults)
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: isSelected ? BuddyColors.green : BuddyColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
