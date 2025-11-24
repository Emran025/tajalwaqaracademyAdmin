import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tajalwaqaracademy/features/settings/presentation/bloc/settings_bloc.dart';

import '../../../../shared/widgets/taj.dart';
import '../../domain/entities/faq_entity.dart';
import '../widgets/submit_ticket_dialog.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<SettingsBloc>().add(FetchFaqs());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('الأسئلة الشائعة'),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<SettingsBloc>(context),
                    child: const SubmitTicketDialog(),
                  ),
                );
              },
              child: StatusTag(lable: 'طلب الدعم'),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        bottom: PreferredSize(preferredSize: Size.zero, child: Container()),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          if (previous is SettingsLoadSuccess &&
              current is SettingsLoadSuccess) {
            return previous.faqsStatus != current.faqsStatus ||
                previous.faqs != current.faqs;
          }
          return true;
        },
        builder: (context, state) {
          if (state is SettingsLoadSuccess) {
            switch (state.faqsStatus) {
              case SectionStatus.initial:
                return const Center(child: CircularProgressIndicator());
              case SectionStatus.loading:
                return state.faqs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildFaqList(context, state.faqs, true);
              case SectionStatus.failure:
                return Center(
                  child: Text(
                    'حدث خطأ أثناء تحميل الأسئلة:\n${state.error?.message}',
                    textAlign: TextAlign.center,
                  ),
                );
              case SectionStatus.success:
                if (state.faqs.isNotEmpty) {
                  return _buildFaqList(context, state.faqs, false);
                }
                return const Center(
                  child: Text('لم يتم العثور على أسئلة شائعة.'),
                );
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFaqList(
    BuildContext context,
    List<FaqEntity> faqs,
    bool isLoading,
  ) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: faqs.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= faqs.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildFaqItem(context, faqs[index]);
      },
    );
  }

  Widget _buildFaqItem(BuildContext context, FaqEntity faq) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ExpansionTile(
        title: Text(faq.question, style: theme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          Text(
            faq.answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<SettingsBloc>().add(FetchFaqs());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
