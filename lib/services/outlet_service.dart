import '../models/outlet.dart';
import 'api_service.dart';

class OutletService {
  static Future<Map<String, dynamic>> getOutlets({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final result = await ApiService.get(ApiService.ENDPOINT_OUTLETS, queryParams: queryParams);

    if (result['success']) {
      final response = OutletListResponse.fromJson(result['data']);
      return {
        'success': true,
        'data': response,
      };
    }

    return result;
  }

  static Future<Map<String, dynamic>> getOutletById(String id) async {
    final result = await ApiService.get('${ApiService.ENDPOINT_OUTLETS}/$id');

    if (result['success']) {
      final rawData = result['data'];
      print('OutletService.getOutletById RAW DATA: $rawData'); // DEBUG LOG
      
      // Check if the actual outlet object is wrapped in a 'data' key
      final outletMap = (rawData is Map && rawData.containsKey('data')) 
          ? rawData['data'] 
          : rawData;
          
      final outlet = Outlet.fromJson(outletMap);
      print('OutletService.getOutletById PARSED ADDRESSES: ${outlet.addresses.length}'); // DEBUG LOG
      return {
        'success': true,
        'data': outlet,
      };
    }
    
    // If singular 404s, try plural as a fallback - common REST inconsistency
    if (result['message'].toString().contains('404')) {
      print('OutletService.getOutletById trying plural fallback...');
      final pluralResult = await ApiService.get('/v1/outlets/$id');
      if (pluralResult['success']) {
        final rawData = pluralResult['data'];
        final outletMap = (rawData is Map && rawData.containsKey('data')) ? rawData['data'] : rawData;
        return {
          'success': true,
          'data': Outlet.fromJson(outletMap),
        };
      }
    }

    return result;
  }

  static Future<Map<String, dynamic>> getLedgerGroups() async {
    final result = await ApiService.get(ApiService.ENDPOINT_LEDGER_GROUPS);

    if (result['success']) {
      final body = result['data'];
      final List dataList;
      if (body is List) {
        dataList = body;
      } else if (body is Map && body.containsKey('data')) {
        dataList = body['data'] as List? ?? [];
      } else {
        dataList = [];
      }
      
      final groups = dataList
          .map((e) => LedgerGroup.fromJson(e))
          .toList();
      return {
        'success': true,
        'data': groups,
      };
    }

    return result;
  }

  static Future<Map<String, dynamic>> getSalesPersons() async {
    final result = await ApiService.get(
      ApiService.ENDPOINT_USERS,
      queryParams: {
        'page': '1',
        'limit': '1000',
      },
    );

    if (result['success']) {
      final body = result['data'];
      final List dataList;
      if (body is List) {
        dataList = body;
      } else if (body is Map && body.containsKey('data')) {
        dataList = body['data'] as List? ?? [];
      } else {
        dataList = [];
      }

      final salesPersons = dataList
          .map((e) => SalesPerson.fromJson(e))
          .toList();
      return {
        'success': true,
        'data': salesPersons,
      };
    }

    return result;
  }

  static Future<Map<String, dynamic>> createOutlet(Map<String, dynamic> data) async {
    return await ApiService.post(ApiService.ENDPOINT_OUTLETS, data);
  }

  static Future<Map<String, dynamic>> getLookupData(String group) async {
    final result = await ApiService.get(ApiService.ENDPOINT_LOOKUP, queryParams: {'group': group});
    print('OutletService.getLookupData($group) result: $result');

    if (result['success']) {
      final body = result['data'];
      final List dataList;
      if (body is List) {
        dataList = body;
      } else if (body is Map && body.containsKey('data')) {
        dataList = body['data'] as List? ?? [];
      } else {
        dataList = [];
      }

      final items = dataList
          .map((e) => LookupItem.fromJson(e))
          .toList();
      return {
        'success': true,
        'data': items,
      };
    }

    return result;
  }
}
