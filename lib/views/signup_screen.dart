import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaptur/controllers/auth_controller.dart';

/// ─────────────────────────────────────────────────────────────
///  SignupScreen
///
///  Design rules:
///   • Reads ONLY from Theme — no hard-coded colours or sizes.
///   • The logo / brand block sits above a card-style form panel.
///   • Works for both Signup and (by toggling one flag) Login.
/// ─────────────────────────────────────────────────────────────

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  // Subtle entrance animation
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // No AppBar — full-bleed custom header
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Brand / Logo block ─────────────────────
                  _BrandHeader(isDark: isDark, colorScheme: cs, textTheme: tt),

                  const SizedBox(height: 40),

                  // ── Form card ─────────────────────────────
                  _FormCard(
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscurePassword: _obscurePassword,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    auth: _auth,
                    isDark: isDark,
                    theme: theme,
                  ),

                  const SizedBox(height: 28),

                  // ── Already have account ───────────────────
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: tt.bodyMedium,
                          children: [
                            TextSpan(
                              text: "Log in",
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Brand Header ──────────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.isDark,
    required this.colorScheme,
    required this.textTheme,
  });

  final bool isDark;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Owl icon in a pill-shaped amber badge
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.camera_outlined, // swap with your SVG logo asset
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),

        Text("Create your\nAccount", style: textTheme.displayMedium),

        const SizedBox(height: 10),

        Text(
          "Join FotoOwl and start sharing moments.",
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// ── Form Card ────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.auth,
    required this.isDark,
    required this.theme,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final AuthController auth;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        // Subtle shadow only in light mode
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Full Name ──────────────────────────────────────
          TextField(
            controller: nameCtrl,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),

          // ── Email ─────────────────────────────────────────
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),

          // ── Password ──────────────────────────────────────
          TextField(
            controller: passwordCtrl,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: onToggleObscure,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Register button ────────────────────────────────
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: auth.isLoading.value
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.primary,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => auth.register(
                        nameCtrl.text.trim(),
                        emailCtrl.text.trim(),
                        passwordCtrl.text.trim(),
                      ),
                      child: const Text("Create Account"),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Divider with OR ───────────────────────────────
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  "OR",
                  style: tt.bodyMedium?.copyWith(letterSpacing: 1),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),

          const SizedBox(height: 20),

          // ── Google button ─────────────────────────────────
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              icon: _GoogleIcon(), // custom G logo
              label: const Text("Continue with Google"),
              onPressed: () => auth.signInWithGoogle(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Google "G" icon drawn in pure Flutter (no asset needed) ──

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple coloured G using a Text widget — replace with Image.asset
    // for the real Google logo once you have it.
    return const Text(
      "G",
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
