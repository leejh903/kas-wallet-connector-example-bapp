import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:kas_wallet_connector_example_bapp/model/error.dart';
import 'package:kas_wallet_connector_example_bapp/screen/login_screen.dart';
import 'package:kas_wallet_connector_example_bapp/service/kas_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool sentVerificationCode = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmCodeController = TextEditingController();
  final _kasService = KasService();

  Future<void> onPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text;
    var res;
    var message;

    var routeToLogin = false;
    if (sentVerificationCode) {
      final newPassword =
          '0x${sha256.convert(utf8.encode(passwordController.text))}';
      final confirmCode = confirmCodeController.text;
      res = await _kasService.confirmVerificationCode(
          email, newPassword, confirmCode);
      message = 'password reset successfully';
      routeToLogin = res is! KasError;
    }
    if (!sentVerificationCode) {
      res = await _kasService.sendVerificationCode(email);
      setState(() {
        sentVerificationCode = true;
      });
      message = 'Verification code sent. Check your email';
    }

    if (res is KasError) {
      message = 'Error: ${res.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );

    if (routeToLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Reset password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          readOnly: sentVerificationCode,
                          controller: emailController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => EmailValidator.validate(value!)
                              ? null
                              : "Please enter a valid email",
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        sentVerificationCode
                            ? const SizedBox(
                                height: 20,
                              )
                            : Container(),
                        sentVerificationCode
                            ? TextFormField(
                                controller: passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your new password';
                                  }
                                  return null;
                                },
                                maxLines: 1,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  hintText: 'Enter your new password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            : Container(),
                        sentVerificationCode
                            ? const SizedBox(
                                height: 20,
                              )
                            : Container(),
                        sentVerificationCode
                            ? TextFormField(
                                controller: confirmCodeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter verfication code';
                                  }
                                  return null;
                                },
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'Verification Code',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          onPressed: onPressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                          ),
                          child: sentVerificationCode
                              ? const Text('Reset Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ))
                              : const Text(
                                  'Send Verification Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
