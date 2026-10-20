import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/hover_link.dart';

/// Login. Hanya muncul saat pengguna mengakses fitur privat.
/// [redirectTo] berasal dari `?from=` dan sudah disanitasi oleh router.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _notice(BuildContext context) {
    if (AppState.instance.pendingFavoriteId != null) {
      return context.tr('login.noticeSave');
    }
    if (widget.redirectTo != null) {
      return context.tr('login.noticeGo');
    }
    return null;
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      // POST /api/auth/login -> token JWT disimpan oleh AppState.
      await AppState.instance.login(_email.text, _password.text);
      if (!mounted) return;
      context.go(widget.redirectTo ?? AppRoutes.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: context.tr('login.tab'),
      color: AppTheme.orange,
      child: AuthCard(
        title: context.tr('login.title'),
        subtitle: context.tr('login.subtitle'),
        notice: _notice(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: context.tr('auth.email'),
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
                validator: (v) => (v == null || !v.contains('@'))
                    ? context.tr('auth.emailInvalid')
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: _hide,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: context.tr('auth.password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _hide
                        ? context.tr('auth.show')
                        : context.tr('auth.hide'),
                    icon: Icon(_hide
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? context.tr('auth.passMin')
                    : null,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _submit,
                child: Text(context.tr('action.login')),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('auth.noAccount')),
                  HoverLink(
                    text: context.tr('action.signup'),
                    color: AppTheme.orange,
                    hoverColor: AppTheme.orangeDark,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    onTap: () => context.go(
                      AppRoutes.registerLocation(from: widget.redirectTo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: HoverLink(
                  text: context.tr('auth.guest'),
                  style: const TextStyle(fontSize: 13),
                  onTap: () => context.go(AppRoutes.home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
