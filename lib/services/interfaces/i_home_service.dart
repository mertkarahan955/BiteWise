import 'package:bitewise/models/home_data_model.dart';

abstract class IHomeService {
  Future<HomeData> fetchHomeData(String userId);
}
