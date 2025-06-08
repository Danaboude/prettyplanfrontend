import 'package:finalproject/providers/language_provider.dart';
import 'package:finalproject/screens/admin_panel_screen.dart';
import 'package:finalproject/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _isSubmitting = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _iconAnimationController, curve: Curves.elasticOut),
    );

    _iconAnimationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isRegisterMode) {
        await authProvider.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // ✅ Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('user_id', authProvider.userId);
      await prefs.setString('full_name', authProvider.fullName);
      await prefs.setString('email', authProvider.email);
      await prefs.setString('role', authProvider.role);
      await prefs.setDouble('account_balance', authProvider.accountBalance);

      // ✅ Navigate based on role
      if (authProvider.role == 'manager') {
        Navigator.pushReplacement(context, PageTransition(AdminPanelScreen()));
      } else {
        Navigator.pushReplacement(context, PageTransition(HomeScreen()));
      }
      final lang =
          Provider.of<LanguageProvider>(context, listen: false); // ✅ Add this

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isRegisterMode
              ? lang.translate('Registered successfully')
              : lang.translate('Logged in successfully')),
          backgroundColor: AppTheme.roseGold,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Directionality(
      textDirection: lang.textDirection,
      child: Scaffold(
        backgroundColor: AppTheme.ivoryWhite,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _iconAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.blushPink,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.roseGold.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppTheme.roseGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      _isRegisterMode
                          ? lang.translate('create_account')
                          : lang.translate('welcome_back'),
                      key: ValueKey<bool>(_isRegisterMode),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.roseGold,
                        fontFamily: 'PlayfairDisplay',
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: AppTheme.roseGold.withOpacity(0.6),
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.roseGold.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_isRegisterMode)
                            Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: lang.translate('full_name'),
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true)
                                      return lang.translate('name_required');
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          _buildTextField(
                            controller: _emailController,
                            label: lang.translate('email'),
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return lang.translate('email_required');
                              if (!value!.contains('@'))
                                return lang.translate('invalid_email');
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: lang.translate('password'),
                            icon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true)
                                return lang.translate('password_required');
                              if (value!.length < 6)
                                return lang.translate('password_too_short');
                              return null;
                            },
                          ),
                          if (_isRegisterMode)
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: lang.translate('confirm_password'),
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return lang
                                          .translate('passwords_do_not_match');
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isRegisterMode
                                          ? lang.translate('register')
                                          : lang.translate('login'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'PlayfairDisplay',
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.roseGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isRegisterMode = !_isRegisterMode;
                                if (_isRegisterMode) {
                                  _iconAnimationController.forward(from: 0);
                                } else {
                                  _iconAnimationController.reverse(from: 1);
                                }
                              });
                            },
                            child: Text(
                              _isRegisterMode
                                  ? lang.translate('already_have_account')
                                  : lang.translate('need_account'),
                              style: TextStyle(
                                color: AppTheme.roseGold,
                                fontFamily: 'PlayfairDisplay',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.roseGold),
        labelStyle: TextStyle(color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppTheme.blushPink),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppTheme.roseGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: AppTheme.ivoryWhite,
      ),
    );
  }
}
