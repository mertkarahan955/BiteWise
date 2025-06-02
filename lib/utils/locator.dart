import 'package:bitewise/view/auth_view.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:bitewise/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

setupLocator() {
  locator.registerLazySingleton(() => AuthRepository());
  locator.registerFactoryParam<AuthViewmodel, AuthMode, void>((initialMode, _) {
    return AuthViewmodel(initialMode: initialMode);
  });
}
