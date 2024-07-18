import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:web/core/services/auth_services.dart';
import 'package:web/core/services/profile_service.dart';
import 'package:web/profile/bloc/profile_bloc.dart';
import 'package:web/shared/input_validator.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPasswordRepeatController = TextEditingController();

  final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updatePasswordFormKey = GlobalKey<FormState>();

  void _clearInputs() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _newPasswordRepeatController.clear();
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(ProfileService())..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeroIcon(
                    HeroIcons.user,
                    color: Color.fromRGBO(72, 2, 151, 1),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Profil',
                    style: TextStyle(
                      color: Color.fromRGBO(72, 2, 151, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          toolbarHeight: 64.0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProfileLoaded) {
                      return _buildProfileForm(context, state.profile);
                    } else if (state is ProfileNotFound) {
                      return const Center(child: Text('Profil non trouvé'));
                    } else if (state is ProfileError) {
                      return Center(
                          child: Text('Erreur: ${state.errorMessage}'));
                    } else if (state is ProfilePasswordUpdated) {
                      _logout(context);
                      return const Center(child: Text('Profil'));
                    } else {
                      return const Center(child: Text('Profil'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<ProfileBloc>(context),
          child: Builder(
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Modifier le mot de passe',
                          style: TextStyle(fontSize: 20.0)),
                      const SizedBox(height: 16),
                      Form(
                        key: _updatePasswordFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _oldPasswordController,
                              decoration: const InputDecoration(
                                  labelText: 'Ancien mot de passe'),
                              obscureText: true,
                              validator: InputValidator.validatePassword,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordController,
                              decoration: const InputDecoration(
                                  labelText: 'Nouveau mot de passe'),
                              obscureText: true,
                              validator: (value) {
                                if (value != _newPasswordController.text) {
                                  return "Les mots de passe doivent correspondre";
                                } else {
                                  return InputValidator.validatePassword(value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordRepeatController,
                              decoration: const InputDecoration(
                                  labelText: 'Répéter nouveau mot de passe'),
                              obscureText: true,
                              validator: (value) {
                                if (value != _newPasswordController.text) {
                                  return "Les mots de passe doivent correspondre";
                                } else {
                                  return InputValidator.validatePassword(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _clearInputs();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Fermer',
                                style: TextStyle(color: Colors.red)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_updatePasswordFormKey.currentState!
                                  .validate()) {
                                context
                                    .read<ProfileBloc>()
                                    .add(UpdateProfilePassword(
                                      _oldPasswordController.text,
                                      _newPasswordController.text,
                                    ));
                                _clearInputs();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Modifier'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileForm(BuildContext context, dynamic profile) {
    _firstnameController.text = profile['firstname'];
    _lastnameController.text = profile['lastname'];
    _emailController.text = profile['email'];

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(50, 50, 50, 0.1),
                spreadRadius: 0,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return Form(
                key: _updateFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _firstnameController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: InputValidator.validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: InputValidator.validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: InputValidator.validateEmail,
                      ),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () {
                          if (_updateFormKey.currentState!.validate()) {
                            context.read<ProfileBloc>().add(UpdateProfile(
                                _firstnameController.text,
                                _lastnameController.text,
                                _emailController.text));
                          }
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(249, 178, 53, 1),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(249, 178, 53, 0.1),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Modifier le profil",
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextButton(
                        onPressed: () {
                          _showUpdatePasswordDialog(context);
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(249, 178, 53, 1),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(249, 178, 53, 0.1),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Modifier le mot de passe",
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
              );
            },
          ),
        ),
      ),
    );
  }

}
