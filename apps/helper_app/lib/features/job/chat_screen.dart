import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madadgaar_core/madadgaar_core.dart';

const _quickMessages = [
  "I'm on my way.",
  "I've arrived.",
  'What vehicle are you driving?',
  'Almost there.',
];

final _customerForRequestProvider = FutureProvider.family.autoDispose<AppUser?, String>((ref, customerId) {
  return ref.watch(madadgaarApiProvider).getUser(customerId);
});

class ChatScreen extends ConsumerStatefulWidget {
  final String requestId;
  const ChatScreen({super.key, required this.requestId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send(String text) {
    if (text.trim().isEmpty) return;
    ref.read(chatControllerProvider(widget.requestId).notifier).send(text.trim());
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(requestLiveProvider(widget.requestId));
    final messages = ref.watch(chatControllerProvider(widget.requestId));
    final me = ref.watch(currentUserProvider);
    final customerAsync = live.request != null ? ref.watch(_customerForRequestProvider(live.request!.customerId)) : null;

    return Scaffold(
      appBar: AppBar(title: Text(customerAsync?.value?.name ?? 'Chat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickMessages.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) => ActionChip(label: Text(_quickMessages[i], style: AppTextStyles.caption), onPressed: () => _send(_quickMessages[i])),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text('Say hello 👋', style: AppTextStyles.body.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final mine = m.senderId == me?.id;
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: mine ? AppColors.primary : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(m.text, style: AppTextStyles.body.copyWith(color: mine ? Colors.white : null)),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Type a message…'), onSubmitted: _send)),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(onPressed: () => _send(_controller.text), icon: const Icon(Icons.send_rounded)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
