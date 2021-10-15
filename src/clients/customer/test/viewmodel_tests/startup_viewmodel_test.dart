import 'package:customer/app/app.router.dart';
import 'package:customer/models/application_models.dart';
import 'package:customer/ui/startup/startup_viewmodel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

StartUpViewModel _getModel() => StartUpViewModel();

void main() {
  group('StartupViewmodelTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());

    group('runStartupLogic -', () {
      test('When called should initiliase EnvironmentService', () async {
        final environmentService = getAndRegisterEnvironmentService();
        var model = _getModel();
        await model.runStartupLogic();
        verify(environmentService.initialise());
      });

      test(
          'When called should initiliase PlacesService with api from EnvironmentService',
          () async {
        getAndRegisterEnvironmentService(value: 'its-me');
        final placesService = getAndRegisterPlacesService();
        var model = _getModel();
        await model.runStartupLogic();
        verify(placesService.initialize(apiKey: env['GOOGLE_MAPS_API_KEY']!));
      });

      test(
          'When called should check if we have a logged in user on UserService',
          () async {
        final userService = getAndRegisterUserService();
        final model = _getModel();
        await model.runStartupLogic();
        verify(userService.hasLoggedInUser);
      });

      test('When we have no logged in user, should navigate to the login view',
          () async {
        final navigationService = getAndRegisterNavigationService();
        final model = _getModel();
        await model.runStartupLogic();

        verify(navigationService.replaceWith(Routes.loginView));
      });

      test(
          'When hasLoggedInUser is true, should call syncUserAccount on the userService',
          () async {
        final userService = getAndRegisterUserService(hasLoggedInUser: true);
        final model = _getModel();
        await model.runStartupLogic();

        verify(userService.syncUserAccount());
      });

      test(
          'When hasLoggedInUser is true, should get currentUser from userService',
          () async {
        final userService = getAndRegisterUserService(hasLoggedInUser: true);
        final model = _getModel();
        await model.runStartupLogic();

        verify(userService.currentUser);
      });

      test(
          'When currentUser does NOT have default address, navigate to addressSelectionView',
          () async {
        final navigationService = getAndRegisterNavigationService();
        getAndRegisterUserService(hasLoggedInUser: true);
        final model = _getModel();
        await model.runStartupLogic();

        verify(navigationService.navigateTo(Routes.addressSelectionView));
      });

      test('When currentUser HAS a default address, navigate to homeView',
          () async {
        final navigationService = getAndRegisterNavigationService();
        getAndRegisterUserService(
            hasLoggedInUser: true,
            currentUser: User(id: 'id', defaultAddress: 'i-am-here'));
        final model = _getModel();
        await model.runStartupLogic();

        verify(navigationService.replaceWith(Routes.homeView));
      });
    });
  });
}
