import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web/shared/input_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();
  bool _isError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
  }

  Future<void> _login(BuildContext context, VoidCallback onSuccess) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await dio.post('$apiUrl/api/auth/login',
          data: {'password': password.text, 'email': email.text});

      if (response.statusCode == 200) {
        await AuthService.saveJwt(response.data["token"]);
        onSuccess.call();
      } else {
        setState(() {
          _isError = true;
        });
      }
    } on DioException {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(72, 2, 151, 1),
                  Color.fromRGBO(51, 2, 108, 1),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: constraints.maxHeight * 0.8,
                              child: Image.asset(
                                'assets/login.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: Text(
                            "Studies",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 37,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        Builder(builder: (context) {
                          if (_isError) {
                            return const Column(
                              children: [
                                Text(
                                  "Votre email ou mot de passe n'est pas bon",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 20)
                              ],
                            );
                          }

                          return Container();
                        }),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: email,
                                decoration: const InputDecoration(
                                  hintText: "Enter your email",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: HeroIcon(
                                    HeroIcons.atSymbol,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: InputValidator.validateEmail
                              ),
                              TextFormField(
                                controller: password,
                                decoration: const InputDecoration(
                                  hintText: "Enter your password",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: HeroIcon(
                                    HeroIcons.lockClosed,
                                    color: Colors.white,
                                  ),
                                ),
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                validator: InputValidator.validatePassword
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              TextButton(
                                onPressed: !_isLoading 
                                    ? () {
                                      if (_formKey.currentState!.validate()) {
                                        _login(context, () {
                                          if (!mounted) {
                                            return;
                                          }

                                          GoRouter router = GoRouter.of(context);
                                          router.go('/');
                                        });
                                      }
                                    }
                                  : null,
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(249, 178, 53, 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(249, 178, 53, 0.1),
                                        spreadRadius: 0,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Se connecter",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              const Text(
                                "ou",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              TextButton(
                                onPressed: () {
                                  GoRouter router = GoRouter.of(context);
                                  router.go('/register');
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(249, 178, 53, 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(249, 178, 53, 0.1),
                                        spreadRadius: 0,
                                        blurRadius: 5,
                                        offset: Offset(
                                            0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Créer son compte",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
