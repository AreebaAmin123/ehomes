import 'client/api_client.dart';

/// 🔹 **Category Service**
class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getCategories() async {
    return _apiClient.get('/get_categories.php');
  }

}
