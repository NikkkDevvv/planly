import '../../../data/models/user_model.dart';

abstract class ProfileEvent {}

class FetchProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UserModel user;
  UpdateProfile(this.user);
}
