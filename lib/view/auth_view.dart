import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:bitewise/utils/color.dart';
import 'package:bitewise/utils/image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { login, signup }

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewmodel = Provider.of<AuthViewmodel>(context);

    return Scaffold(
      backgroundColor: ColorUtil.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Spacer(flex: 1),
                Center(child: ImageTransformers(ImageConstants.logo).svgLogo),
                const SizedBox(height: 32),

                // Only show name field in signup mode
                if (viewmodel.mode == AuthMode.signup) ...[
                  _buildTextField(
                    controller: viewmodel.nameController,
                    label: 'Full Name',
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                _buildTextField(
                  controller: viewmodel.emailController,
                  label: 'Email',
                ),
                const SizedBox(height: 16),

                // Only show phone field in signup mode
                if (viewmodel.mode == AuthMode.signup) ...[
                  _buildTextField(
                    controller: viewmodel.phoneController,
                    label: 'Phone Number',
                  ),
                  const SizedBox(height: 16),
                ],

                // Password field
                _buildTextField(
                  controller: viewmodel.passwordController,
                  label: 'Password',
                  obscureText: viewmodel.obscurePassword,
                  suffixIcon: IconButton(
                    icon:
                        ImageTransformers(ImageConstants.passwordHintEye).icon,
                    onPressed: viewmodel.togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 8),

                // Forgot password (login only)
                if (viewmodel.mode == AuthMode.login)
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: ColorUtil.primaryColor),
                    ),
                  ),

                // Terms checkbox (signup only)
                if (viewmodel.mode == AuthMode.signup) ...[
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: viewmodel.acceptTerms,
                    onChanged: viewmodel.toggleAcceptTerms,
                    title: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "I agree to BiteWise's ",
                          style: TextStyle(color: ColorUtil.primaryColor),
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Show terms dialog
                            },
                          text: "Terms of Service and Privacy Policy",
                          style: TextStyle(
                            color: ColorUtil.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],

                // Submit button
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewmodel.isLoading
                          ? null
                          : () {
                              viewmodel.submitForm(context,
                                  isFormValid:
                                      _formKey.currentState?.validate() ??
                                          false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorUtil.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: viewmodel.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              viewmodel.mode == AuthMode.login
                                  ? "Login"
                                  : "Sign Up",
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ),

                // Toggle between login/signup
                Spacer(flex: 2),
                Center(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: viewmodel.mode == AuthMode.login
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: const TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = viewmodel.toggleMode,
                        text: viewmodel.mode == AuthMode.login
                            ? "Sign Up"
                            : "Log In",
                        style: TextStyle(color: ColorUtil.primaryColor),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        labelText: label,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
