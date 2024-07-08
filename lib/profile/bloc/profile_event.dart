part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String firstname;
  final String lastname;
  final String email;

  UpdateProfile(this.firstname, this.lastname, this.email);
}

class UpdateProfilePassword extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  UpdateProfilePassword(this.oldPassword, this.newPassword);
}