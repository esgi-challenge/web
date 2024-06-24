import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:go_router/go_router.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:dio/dio.dart';

String apiUrl = "http://127.0.0.1:8080";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final firstname = TextEditingController();
  final lastname = TextEditingController();
  final password = TextEditingController();
  final dio = Dio();
  bool _isError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    firstname.dispose();
    lastname.dispose();
    password.dispose();
  }

  Future<void> _register(BuildContext context, VoidCallback onSuccess) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await dio.post('$apiUrl/api/auth/register',
        data: {'email': email.text ,'firstname': firstname.text, 'lastname': lastname.text, 'password': password.text});
      
      if (response.statusCode == 201) {
        await AuthService.saveJwt(response.data["token"]);
        onSuccess.call();
      } else {
        _handleError(response.statusCode);
      }
    } on DioException catch(e) {
      if (e.response != null) {
        _handleError(e.response?.statusCode);
      } else {
        setState(() {
          _isError = true;
          _errorMessage = 'Erreur durant l\'enregistrement';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      }); 
    }
  }

  void _handleError(int? statusCode) {
    setState(() {
      _isError = true;
      if (statusCode == 409) {
        _errorMessage = 'Email déjà utilisé';
      } else if (statusCode != null && statusCode >= 500) {
        _errorMessage = 'Erreur serveur';
      } else {
        _errorMessage = 'Erreur durant l\'enregistrement';
      }
    });
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
                            return Column(
                              children: [
                                Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 20)
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
                                  hintText: "Entrez votre email",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: HeroIcon(
                                    HeroIcons.atSymbol,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'L\'email est requise';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: firstname,
                                decoration: const InputDecoration(
                                  hintText: "Entrez votre prénom",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: HeroIcon(
                                    HeroIcons.user,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le prénom est requis';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: lastname,
                                decoration: const InputDecoration(
                                  hintText: "Entrez votre nom de famille",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: HeroIcon(
                                    HeroIcons.user,
                                    color: Colors.white,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le nom de famille est requis';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: password,
                                decoration: const InputDecoration(
                                  hintText: "Entrez votre mot de passe",
                                  hintStyle: TextStyle(color: Colors.white),
                                  prefixIcon: HeroIcon(
                                    HeroIcons.lockClosed,
                                    color: Colors.white,
                                  ),
                                ),
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le mot de passe est requis';
                                  } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z]).{8,}$').hasMatch(value)) {
                                    return 'Le mot de passe doit contenir au moins 8 caractères, une majuscule et une minuscule';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              TextButton(
                                onPressed: !_isLoading 
                                    ? () {
                                      if (_formKey.currentState!.validate()) {
                                        _register(context, () {
                                          if (!mounted) {
                                            return;
                                          }

                                          GoRouter router = GoRouter.of(context);
                                          router.push('/');
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
                                  router.go('/login');
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
