import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/modules/auth/controllers/auth_controller.dart';
import 'package:kaptur/routes/app_pages.dart';
import 'package:kaptur/widgets/theme_toggle_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoggerUtility.info("In login screen ");
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // Brand / Logo block
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.camera_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text("Welcome\nBack", style: tt.displayMedium),
                          const SizedBox(height: 10),
                          Text(
                            "Log in to continue your moments.",
                            style: tt.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor),
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
                            // Email
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Login button
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: _auth.isLoading.value
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
                                        onPressed: () => _auth.login(
                                          _emailCtrl.text.trim(),
                                          _passwordCtrl.text.trim(),
                                        ),
                                        child: const Text("Log In"),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Divider with OR
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: theme.dividerColor),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    "OR",
                                    style: tt.bodyMedium?.copyWith(
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: theme.dividerColor),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Google button
                            SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                icon: const Text(
                                  "G",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                                label: const Text("Continue with Google"),
                                onPressed: () => _auth.signInWithGoogle(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign up link
                      Center(
                        child: TextButton(
                          onPressed: () => Get.toNamed(Routes.signup),
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: tt.bodyMedium,
                              children: [
                                TextSpan(
                                  text: "Sign Up",
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
            const Positioned(top: 10, right: 10, child: ThemeToggleButton()),
          ],
        ),
      ),
    );
  }
}
