import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:web/core/services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService profileService;

  ProfileBloc(this.profileService) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await profileService.getMe();

        if (profile != null && profile.isNotEmpty) {
          emit(ProfileLoaded(profile: profile));
        } else {
          emit(ProfileNotFound());
        }
      } on Exception catch (e) {
        emit(ProfileError(errorMessage: e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final updatedProfile = await profileService.updateProfile(event.firstname, event.lastname, event.email);

        if (updatedProfile != null) {
          emit(ProfileLoaded(profile: updatedProfile));
        } else {
          emit(ProfileError(errorMessage: "L'utilisateur pas pu être modifié"));
        }
      } on Exception catch (e) {
        emit(ProfileError(errorMessage: e.toString()));
      }
    });

    on<UpdateProfilePassword>((event, emit) async {
      emit(ProfileLoading());
      try {
        final updatedProfile = await profileService.updateProfilePassword(event.oldPassword, event.newPassword);

        if (updatedProfile != null) {
          emit(ProfilePasswordUpdated());
        } else {
          emit(ProfileError(errorMessage: "L'utilisateur pas pu être modifié"));
        }
      } on Exception catch (e) {
        emit(ProfileError(errorMessage: e.toString()));
      }
    });
  }
}
