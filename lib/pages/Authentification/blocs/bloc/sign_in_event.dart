part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInRequired  extends SignInEvent{
  final String user;
  final String password;

  const SignInRequired(this.user,this.password);

  @override
  List<Object> get props => [user,password];
}

class SignOutRequired extends SignInEvent {

}