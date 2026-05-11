import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../utils/validators.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  final _supabaseService = SupabaseService();

  // Login form
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  String? _loginEmailError;
  String? _loginPasswordError;
  bool _loginPasswordVisible = false;

  // Signup form
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  String? _signupNameError;
  String? _signupEmailError;
  String? _signupPasswordError;
  String? _signupConfirmPasswordError;
  bool _signupPasswordVisible = false;
  bool _signupConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _floatingController.dispose();
    _fadeController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    final emailError = Validators.validateEmail(_loginEmailController.text);
    final passwordError = Validators.validatePassword(
      _loginPasswordController.text,
    );

    setState(() {
      _loginEmailError = emailError;
      _loginPasswordError = passwordError;
    });

    if (emailError != null || passwordError != null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final response = await _supabaseService.signIn(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      if (response.user != null) {
        // Check if user has completed onboarding
        final profile = await _supabaseService.getUserProfile();

        if (!mounted) return;
        if (profile != null) {
          // User has profile, go to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // User exists but no profile, complete onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      _showErrorDialog(AppLocalizations.of(context)!.loginFailed, e.toString());
    }
  }

  Future<void> _handleSignup() async {
    HapticFeedback.mediumImpact();
    final nameError = Validators.validateName(_signupNameController.text);
    final emailError = Validators.validateEmail(_signupEmailController.text);
    final passwordError = Validators.validatePassword(
      _signupPasswordController.text,
    );
    final confirmPasswordError =
        _signupPasswordController.text != _signupConfirmPasswordController.text
        ? AppLocalizations.of(context)!.confirmPassword
        : null;

    setState(() {
      _signupNameError = nameError;
      _signupEmailError = emailError;
      _signupPasswordError = passwordError;
      _signupConfirmPasswordError = confirmPasswordError;
    });

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null)
      return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final response = await _supabaseService.signUp(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
        name: _signupNameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      // Check if email confirmation is required
      if (response.session == null) {
        _showInfoDialog(
          AppLocalizations.of(context)!.verifyEmail,
          'We sent a verification email to ${_signupEmailController.text.trim()}. Please check your inbox and click the verification link to complete your registration.',
        );
        return;
      }

      // Success - go to onboarding to collect profile info
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      _showErrorDialog(AppLocalizations.of(context)!.signUpFailed, e.toString());
    }
  }

  Future<void> _handleForgotPassword() async {
    HapticFeedback.lightImpact();
    final emailController = TextEditingController();

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          AppLocalizations.of(context)!.resetPassword,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                hintText: AppLocalizations.of(context)!.enterEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, emailController.text),
            child: Text(
              AppLocalizations.of(context)!.sendResetLink,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    // Validate email
    final emailError = Validators.validateEmail(result);
    if (emailError != null) {
      _showErrorDialog(AppLocalizations.of(context)!.invalidEmail, emailError);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      await _supabaseService.resetPassword(result.trim());

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      _showInfoDialog(
        AppLocalizations.of(context)!.resetLinkSent,
        'We\'ve sent a password reset link to $result. Please check your email and follow the instructions.',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading

      _showErrorDialog(AppLocalizations.of(context)!.resetFailed, e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          message.replaceAll('Exception: ', ''),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final topPadding = isSmallScreen ? 16.0 : 30.0;
    final logoSpacing = isSmallScreen ? 20.0 : 35.0;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Animated background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.surface,
                    AppColors.card,
                  ],
                ),
              ),
            ),

            // Floating orbs for visual interest
            ..._buildFloatingOrbs(),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    SizedBox(height: topPadding),

                    // Animated Logo
                    _buildAnimatedLogo(isSmallScreen),

                    SizedBox(height: logoSpacing),

                    // Glass morphism tab bar
                    _buildGlassTabBar(),

                    const SizedBox(height: 16),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(isSmallScreen),
                          _buildSignupForm(isSmallScreen),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      Positioned(
        top: 100,
        right: -50,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                math.sin(_floatingController.value * 2 * math.pi) * 20,
              ),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: 150,
        left: -50,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                math.cos(_floatingController.value * 2 * math.pi) * 30,
              ),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildAnimatedLogo(bool isSmallScreen) {
    final iconSize = isSmallScreen ? 36.0 : 48.0;
    final titleSize = isSmallScreen ? 32.0 : 42.0;
    final taglineSize = isSmallScreen ? 13.0 : 15.0;
    final iconPadding = isSmallScreen ? 16.0 : 20.0;
    final spaceBetween = isSmallScreen ? 12.0 : 20.0;

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            math.sin(_floatingController.value * 2 * math.pi) * 8,
          ),
          child: Column(
            children: [
              // Animated icon with glow
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: spaceBetween),

              // App name with gradient
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: Text(
                  AppLocalizations.of(context)!.appName,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Tagline
              Text(
                AppLocalizations.of(context)!.tagline,
                style: TextStyle(
                  fontSize: taglineSize,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.5),
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        padding: EdgeInsets.zero,
        tabs: [
          Tab(text: AppLocalizations.of(context)!.login, height: 44),
          Tab(text: AppLocalizations.of(context)!.signUp, height: 44),
        ],
      ),
    );
  }

  Widget _buildLoginForm(bool isSmallScreen) {
    final fieldSpacing = isSmallScreen ? 14.0 : 18.0;
    final formPadding = isSmallScreen ? 20.0 : 24.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(formPadding),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            TextField(
              controller: _loginEmailController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                hintText: AppLocalizations.of(context)!.enterEmail,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                errorText: _loginEmailError,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (_) {
                if (_loginEmailError != null) {
                  setState(() => _loginEmailError = null);
                }
              },
            ),
            SizedBox(height: fieldSpacing),

            // Password
            TextField(
              controller: _loginPasswordController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              obscureText: !_loginPasswordVisible,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                hintText: AppLocalizations.of(context)!.enterPassword,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _loginPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _loginPasswordVisible = !_loginPasswordVisible,
                    );
                  },
                ),
                errorText: _loginPasswordError,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (_) {
                if (_loginPasswordError != null) {
                  setState(() => _loginPasswordError = null);
                }
              },
            ),
            const SizedBox(height: 8),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Login Button with hover effect
            SizedBox(
              height: isSmallScreen ? 50 : 56,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(bool isSmallScreen) {
    final fieldSpacing = isSmallScreen ? 14.0 : 16.0;
    final formPadding = isSmallScreen ? 20.0 : 24.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(formPadding),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            TextField(
              controller: _signupNameController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fullName,
                hintText: AppLocalizations.of(context)!.enterFullName,
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                errorText: _signupNameError,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (_) {
                if (_signupNameError != null) {
                  setState(() => _signupNameError = null);
                }
              },
            ),
            SizedBox(height: fieldSpacing),

            // Email
            TextField(
              controller: _signupEmailController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email,
                hintText: AppLocalizations.of(context)!.enterEmail,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                errorText: _signupEmailError,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (_) {
                if (_signupEmailError != null) {
                  setState(() => _signupEmailError = null);
                }
              },
            ),
            SizedBox(height: fieldSpacing),

            // Password
            TextField(
              controller: _signupPasswordController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              obscureText: !_signupPasswordVisible,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
                hintText: AppLocalizations.of(context)!.createPasswordHint,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _signupPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _signupPasswordVisible = !_signupPasswordVisible,
                    );
                  },
                ),
                errorText: _signupPasswordError,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (_) {
                if (_signupPasswordError != null) {
                  setState(() => _signupPasswordError = null);
                }
              },
            ),
            SizedBox(height: fieldSpacing),

            // Confirm Password
            TextField(
              controller: _signupConfirmPasswordController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              obscureText: !_signupConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSignup(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.confirmPassword,
                hintText: AppLocalizations.of(context)!.reenterPassword,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _signupConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _signupConfirmPasswordVisible =
                          !_signupConfirmPasswordVisible,
                    );
                  },
                ),
                errorText: _signupConfirmPasswordError,
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (_) {
                if (_signupConfirmPasswordError != null) {
                  setState(() => _signupConfirmPasswordError = null);
                }
              },
            ),
            SizedBox(height: isSmallScreen ? 20 : 28),

            // Signup Button with enhanced shadow
            SizedBox(
              height: isSmallScreen ? 50 : 56,
              child: ElevatedButton(
                onPressed: _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.createAccount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
          ],
        ),
      ),
    );
  }
}
