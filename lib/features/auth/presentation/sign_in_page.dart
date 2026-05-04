import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Shokuba')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(20),
              shrinkWrap: true,
              children: [
                Text(
                  '일본에서 일하는 한국인을 위한 익명 커뮤니티',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '일본 회사 이메일로 인증하고, 실명 없이 직장과 생활 이야기를 나눌 수 있습니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    labelText: '회사 이메일',
                    hintText: 'name@company.co.jp',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  onSubmitted: (_) => controller.sendMagicLink(
                    _emailController.text,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => controller.sendMagicLink(_emailController.text),
                  icon: state.isLoading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mark_email_read_outlined),
                  label: const Text('인증 링크 전송'),
                ),
                const SizedBox(height: 16),
                if (!state.isConfigured)
                  const _Notice(
                    icon: Icons.settings_outlined,
                    text:
                        'SUPABASE_URL과 SUPABASE_ANON_KEY를 dart-define으로 설정해 주세요.',
                  ),
                if (state.sentToEmail != null)
                  _Notice(
                    icon: Icons.check_circle_outline,
                    text: '${state.sentToEmail}로 인증 링크를 보냈습니다.',
                  ),
                if (state.errorMessage != null)
                  _Notice(
                    icon: Icons.error_outline,
                    text: state.errorMessage!,
                    isError: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = isError ? colors.error : colors.onSecondaryContainer;
    final background =
        isError ? colors.errorContainer : colors.secondaryContainer;

    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: TextStyle(color: foreground)),
            ),
          ],
        ),
      ),
    );
  }
}
