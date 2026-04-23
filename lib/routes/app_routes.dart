part of 'app_pages.dart';

abstract class Routes {
  static const login = _Paths.login;
  static const signup = _Paths.signup;
  static const home = _Paths.home;
}

abstract class _Paths {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
}
