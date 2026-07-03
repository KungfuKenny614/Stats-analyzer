import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stats_analyzer/providers/auth_provider.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: DSColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DSSpacing.xl),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: DSColors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: DSColors.border.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DSSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: DSColors.info,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.diamond_rounded,
                              color: DSColors.textInverse,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: DSSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DiamondEdge',
                                style: DSTypography.headingSM.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Sports Analytics',
                                style: DSTypography.caption.copyWith(
                                  color: DSColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: DSSpacing.xl),
                      
                      // Title
                      Text(
                        _isLogin ? 'Welcome Back' : 'Create Account',
                        style: DSTypography.headingMD.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      Text(
                        _isLogin 
                            ? 'Sign in to continue to your dashboard' 
                            : 'Get started with DiamondEdge today',
                        style: DSTypography.bodySM.copyWith(
                          color: DSColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: DSSpacing.xl),
                      
                      // Error message
                      if (_error.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(DSSpacing.md),
                          decoration: BoxDecoration(
                            color: DSColors.negativeSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: DSColors.negative.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: DSColors.negative,
                                size: 18,
                              ),
                              const SizedBox(width: DSSpacing.sm),
                              Expanded(
                                child: Text(
                                  _error,
                                  style: DSTypography.bodySM.copyWith(
                                    color: DSColors.negative,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (_error.isNotEmpty) const SizedBox(height: DSSpacing.md),
                      
                      // Name field (only on sign up)
                      if (!_isLogin)
                        Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(height: DSSpacing.md),
                          ],
                        ),
                      
                      // Email field
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                      ),
                      const SizedBox(height: DSSpacing.md),
                      
                      // Password field
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_rounded 
                                  : Icons.visibility_off_rounded,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        obscureText: _obscurePassword,
                      ),
                      
                      const SizedBox(height: DSSpacing.xl),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  setState(() => _error = '');
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text.trim();
                                  
                                  if (email.isEmpty || password.isEmpty) {
                                    setState(() => _error = 'Please fill in all fields');
                                    return;
                                  }
                                  
                                  if (!_isLogin && _nameController.text.trim().isEmpty) {
                                    setState(() => _error = 'Please enter your name');
                                    return;
                                  }
                                  
                                  bool success;
                                  if (_isLogin) {
                                    success = await authProvider.signIn(email, password);
                                  } else {
                                    success = await authProvider.register(
                                      email, 
                                      password,
                                      name: _nameController.text.trim(),
                                    );
                                  }
                                  
                                  if (!success) {
                                    setState(() => _error = 'Invalid credentials. Please try again.');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DSColors.info,
                            foregroundColor: DSColors.textInverse,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Sign In' : 'Create Account',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: DSSpacing.md),
                      
                      // Demo account button
                      OutlinedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                await authProvider.signInAsDemo();
                              },
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Try Demo Account'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: DSColors.info.withOpacity(0.5)),
                        ),
                      ),
                      
                      const SizedBox(height: DSSpacing.lg),
                      
                      // Toggle login/signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin 
                                ? "Don't have an account?" 
                                : "Already have an account?",
                            style: DSTypography.bodySM.copyWith(
                              color: DSColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                _error = '';
                              });
                            },
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Sign In',
                              style: DSTypography.label.copyWith(
                                color: DSColors.info,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
