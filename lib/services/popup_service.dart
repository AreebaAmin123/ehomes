import '../models/popup_model.dart';
import 'client/api_client.dart';

class PopupService {
  final ApiClient _apiClient = ApiClient();

  Future<PopupModel> fetchPopupImages() async {
    try {
      final response = await _apiClient.get('/app_popup.php');
      if (response != null && response['success'] == true) {
        return PopupModel.fromJson(response);
      } else {
        return PopupModel(success: false, banners: []);
      }
    } catch (e) {
      throw Exception('Error fetching popup images: $e');
    }
  }
}
