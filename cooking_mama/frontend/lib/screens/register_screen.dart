import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../l10n/app_localizations.dart';
import '../router/routes.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_card.dart';
import '../widgets/hover_link.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _notice(BuildContext context) {
    if (AppState.instance.pendingFavoriteId != null) {
      return context.tr('reg.noticeSave');
    }
    if (widget.redirectTo != null) {
      return context.tr('reg.noticeGo');
    }
    return null;
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      // POST /api/auth/register -> langsung login (token JWT dari server).
      await AppState.instance.register(_name.text, _email.text, _password.text);
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
      title: context.tr('reg.tab'),
      color: AppTheme.orange,
      child: AuthCard(
        title: context.tr('reg.title'),
        subtitle: context.tr('reg.subtitle'),
        notice: _notice(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: context.tr('reg.name'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.tr('reg.nameReq')
                    : null,
              ),
              const SizedBox(height: 14),
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
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: context.tr('auth.password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? context.tr('auth.passMin')
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: context.tr('reg.confirm'),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v != _password.text ? context.tr('reg.mismatch') : null,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _submit,
                child: Text(context.tr('action.signup')),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('auth.haveAccount')),
                  HoverLink(
                    text: context.tr('action.login'),
                    color: AppTheme.orange,
                    hoverColor: AppTheme.orangeDark,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                    onTap: () => context.go(
                      AppRoutes.loginLocation(from: widget.redirectTo),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
