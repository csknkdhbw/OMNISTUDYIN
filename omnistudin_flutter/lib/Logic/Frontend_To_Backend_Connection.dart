import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

//AdInGroup class
class AdInGroup {
  String adGroupName;
  String name;
  String description; // Description of the Ad

  AdInGroup({
    // Constructor
    required this.adGroupName,
    required this.name,
    required this.description,
  });

  factory AdInGroup.fromJson(Map<String, dynamic> json) {
    // Factory method to create an AdInGroup object from a JSON object
    return AdInGroup(
      adGroupName: json['ad_group_name'] ?? '',
      name: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

//AdGroup class
class AdGroup {
  String name;
  String description; // Description of the AdGroup

  AdGroup({
    // Constructor
    required this.name,
    required this.description,
  });

  factory AdGroup.fromJson(Map<String, dynamic> json) {
    // Factory method to create an AdGroup object from a JSON object
    return AdGroup(
      name: json['name'],
      description: json['description'],
    );
  }
}

//Provider class
class AdsInGroupProvider with ChangeNotifier {
  List<AdInGroup> _adsInGroup = []; // List of AdInGroup objects

  List<AdInGroup> get adsInGroup =>
      _adsInGroup; // Getter for the list of AdInGroup objects

  void removeAdGroup(int index) {
    // Method to remove an AdGroup object from the list
    _adsInGroup.removeAt(index);
    notifyListeners(); // Notify the listeners that the list has changed
  }

  void setAdGroups(List<AdInGroup> adsInGroup) {
    // Method to set the list of AdInGroup objects
    _adsInGroup = adsInGroup;
    notifyListeners();
  }
}

//Provider class
class AdGroupProvider with ChangeNotifier {
  List<AdGroup> _adGroups = []; // List of AdGroup objects

  List<AdGroup> get adGroups => _adGroups;

  void removeAdGroup(int index) {
    // Method to remove an AdGroup object from the list
    _adGroups.removeAt(index);
    notifyListeners();
  }

  void setAdGroups(List<AdGroup> adGroups) {
    // Method to set the list of AdGroup objects
    _adGroups = adGroups;
    notifyListeners();
  }
}

//Class that connects the frontend to the backend
class FrontendToBackendConnection with ChangeNotifier {
  // baseURL for the backend server running on the PC!
  static const String baseURL = "http://10.0.2.2:8000/";

  // method to get data from the server
  // urlPattern is the backend endpoint url pattern
  static Future<dynamic> getData(String urlPattern,
      {client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + urlPattern; // Construct the full URL
      final response =
          await client.get(Uri.parse(fullUrl), headers: <String, String>{
        // Send a get request to the server
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token',
      });
      if (response.statusCode == 200) {
        // Check if the response is successful
        return json.decode(response.body); // Return the decoded JSON response
      } else {
        throw Exception(
            'Failed to get data: HTTP status ${response.statusCode},  ${response.body}'); // Throw an exception if the response is not successful
      }
    } catch (e) {
      throw Exception('Network error while trying to get data: $e');
    }
  }

  // Method to send post request to the server
  // urlPattern is the backend endpoint url pattern
  // data is the data to be sent to the server in a Map, which is basically a JSON object / Python-dictionary
  static Future<dynamic> postData(String url, Map<String, dynamic> data,
      {client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      final response = await client.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      throw Exception('Network error while trying to post data: $e');
    }
  }

  // Method to send put request to the server
  // urlPattern is the backend endpoint url pattern
  // data is the data to be sent to the server in a Map, which is basically a JSON object / Python-dictionary
  static Future<dynamic> putData(String url, Map<String, dynamic> data,
      {client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      final response = await client.put(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token'
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      throw Exception('Network error while trying to put data: $e');
    }
  }

  // Method to send delete request to the server
  // urlPattern is the backend endpoint url pattern
  static Future<dynamic> deleteData(String url, {client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      final response =
          await client.delete(Uri.parse(fullUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token',
      });
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return json.decode(response.body);
      }
    } catch (e) {
      return jsonDecode(e.toString());
    }
  }

  // Create a FlutterSecureStorage object
  static const storage = FlutterSecureStorage();

  static Future<http.Response> loginStudent(
      String email, String password) async {
    try {
      String fullUrl = "${baseURL}login/";
      var response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var token = jsonDecode(response.body)['jwt'];
        // Speichern Sie den Token mit FlutterSecureStorage
        print('Tokennnnnn:');
        print(token);
        print('Info:');
        print(jsonDecode(response.body)['info']);
        await storage.write(key: 'token', value: token);

        // Ausgabe des gespeicherten Tokens
        String? savedToken = await storage.read(key: 'token');
        print('Saved token:');
        print(savedToken);

        return response;
      } else {
        return response;
      }
    } catch (e) {
      throw Exception('Network error while trying to login: $e');
    }
  }

  static Future<String?> getToken() async {
    // Lesen Sie den Token mit FlutterSecureStorage
    String? token = await storage.read(key: 'token');

    // Ausgabe des abgerufenen Tokens
    print('Retrieved token:');
    print(token);

    if (token != null) {
      await FlutterSessionJwt.saveToken(token);
    }
    print(await FlutterSessionJwt.getPayload());
    print(await FlutterSessionJwt.getExpirationDateTime());
    // Überprüfen Sie, ob der Token abgelaufen is

    if (await FlutterSessionJwt.isTokenExpired()) {
      token = await updateToken();
    }

    return token;
  }

  static Future<String?> updateToken() async {
    print("Updating token");
    try {
      String fullUrl = "${baseURL}update_jwt/";
      var response = await http.get(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var token = jsonDecode(response.body)['jwt'];
        await storage.write(key: 'token', value: token);
        return token;
      } else {
        developer.log(
            'Failed to update token: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to update token: $e');
    }
    return null;
  }

  static Future<void> clearStorage() async {
    await storage.deleteAll();
    print('Storage cleared');
  }

  // Method to get session student
  static Future<dynamic> getSessionStudent({client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + "get_session_student";
      final response = await client.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get session student');
      }
    } catch (e) {
      throw Exception('Network error while trying to get session student: $e');
    }
  }

  // Method to update session student
  static Future<dynamic> updateSessionStudent(
      String sessionId, Map<String, dynamic> data,
      {client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + "change_session_student/$sessionId";
      final response = await client.put(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update session student');
      }
    } catch (e) {
      throw Exception(
          'Network error while trying to update session student: $e');
    }
  }

  // Method to delete session student
  static Future<dynamic> deleteSessionStudent(String sessionId,
      {client = "default"}) async {
    var token = await getToken();
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + "delete_session_student/$sessionId";
      final response = await client.delete(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete session student');
      }
    } catch (e) {
      throw Exception(
          'Network error while trying to delete session student: $e');
    }
  }

  //Ads

  static Future<void> addNewAdsInGroup(
      String adgroupname, String title, String description, var token) async {
    // Method to add a new Ad to a group
    print('Creating new Ad'); //Debugging purposes
    try {
      String fullUrl =
          "${baseURL}create_ads_in_group/"; // Construct the full URL

      var response = await http.post(
        // Send a post request to the server
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
        body: jsonEncode(<String, String>{
          'ad_group_name': adgroupname,
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response is successful
        print('Ad created successfully');
        await fetchAdGroups(token); // Refresh the list of AdGroups
      } else {
        throw Exception(
            'Failed to create Ad: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to create Ad: $e');
    }
  }

  // Method to fetch all the ads
  static Future<List<AdInGroup>> fetchAdGroups(String token) async {
    String fullUrl = "${baseURL}get_adgroups/"; // Construct the full URL

    var response = await http.get(
      // Send a get request to the server
      Uri.parse(fullUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<AdInGroup> adsInGroups = body
          .map((dynamic item) => AdInGroup.fromJson(item))
          .toList(); // Convert the JSON response to a list of AdInGroup objects
      return adsInGroups;
    } else {
      throw Exception('Failed to load new ads');
    }
  }

  // Method to fetch all the ads of a group
  static Future<List<AdInGroup>> getAdsOfGroup(String groupName) async {
    if (groupName == null) {
      // Check if the group name is null
      throw Exception('groupName is null');
    }

    var token = await getToken(); // Fetch the token

    if (token == null) {
      throw Exception('token is null');
    }

    try {
      String fullUrl = "${baseURL}get_ads_of_group/"; // Construct the full URL
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Authorization': '$token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {'ad_group_name': groupName}), // Send the group name in the body
      );
      if (response.statusCode == 200) {
        List<dynamic> body =
            jsonDecode(response.body); // Decode the JSON response
        List<AdInGroup> ads = body
            .map((dynamic item) => AdInGroup.fromJson(item))
            .toList(); // Convert the JSON response to a list of AdInGroup objects
        return ads; // Return the list of AdInGroup objects
      } else {
        throw Exception('Failed to get ads of group');
      }
    } catch (e) {
      throw Exception('Network error while trying to get ads of group: $e');
    }
  }

  // Method to update an ad in a group
  static Future<void> updateAdInGroup(
      String oldName, String newName, String description) async {
    try {
      var token = await getToken(); // Fetch the token

      var response = await http.put(
        Uri.parse('${baseURL}change_ad_in_group/'), // Construct the full URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
        body: jsonEncode(<String, String>{
          'old_name': oldName,
          'new_name': newName,
          'description': description,
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to update Ad: ${response.body}');
        throw Exception('Failed to update Ad');
      }
    } catch (e) {
      print('Error updating Ad: $e');
      throw e;
    }
  }

  // Method to update an adgroup
  static Future<void> updateAdGroup(
      String oldName, String newName, String description) async {
    try {
      var token = await getToken(); // Fetch the token

      var response = await http.put(
        // Send a put request to the server
        Uri.parse('${baseURL}change_adgroup/'), // Construct the full URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
        body: jsonEncode(<String, String>{
          'old_name': oldName,
          'new_name': newName,
          'description': description,
        }),
      );

      if (response.statusCode != 200) {
        print(
            'Failed to update AdGroup: ${response.body}'); // Debugging purposes
        throw Exception('Failed to update AdGroup');
      }
    } catch (e) {
      print('Error updating AdGroup: $e');
      throw e;
    }
  }

  // Method to search for ads
  static Future<List<AdInGroup>> searchAdGroups(String keyword) async {
    String fullUrl =
        "${baseURL}search_adgroups/?keyword=$keyword"; // Construct the full URL
    var response = await http.get(
      // Send a get request to the server
      Uri.parse(fullUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> body =
          jsonDecode(response.body); // Decode the JSON response
      List<AdInGroup> adGroups = body
          .map((dynamic item) => AdInGroup.fromJson(item))
          .toList(); // Convert the JSON response to a list of AdInGroup objects
      return adGroups;
    } else {
      throw Exception('Failed to search ad');
    }
  }

  // Method to delete an ad in a group
  static Future<void> deleteAdInGroup(String adName, var token) async {
    print('Deleting Ad');
    try {
      String fullUrl = "${baseURL}delete_ad_group/"; // Construct the full URL
      var response = await http.delete(
        // Send a delete request to the server
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
        body: jsonEncode({'name': adName}),
      );
      if (response.statusCode == 200) {
        await fetchAdGroups(token); // Refresh the list of AdGroups
      } else {
        throw Exception(
            'Failed to delete Ad'); // Throw an exception if the response is not successful
      }
    } catch (e) {
      throw Exception('Network error while trying to delete Ad: $e');
    }
  }

  // Method to delete an ad group
  static Future<void> deleteAdGroup(
      BuildContext context, index, String name) async {
    String fullUrl = "${baseURL}delete_adgroup/"; // Construct the full URL

    try {
      var token = await getToken(); // Fetch the token

      var response = await http.delete(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token', // Use the token here
        },
        body: jsonEncode(<String, String>{
          'name': name,
        }),
      );
      List<dynamic> body =
          jsonDecode(response.body); // Decode the JSON response
      List<AdInGroup> adGroups = body
          .map((dynamic item) => AdInGroup.fromJson(item))
          .toList(); // Convert the JSON response to a list of AdInGroup objects

      if (response.statusCode == 200) {
        Provider.of<AdsInGroupProvider>(context, listen: false)
            .removeAdGroup(index);
        print('Ad Group deleted successfully');
      } else {
        print(
            'Failed to delete Ad Group: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error deleting Ad Group: $e');
    }
  }

  // Method to get an ad group
  static Future<void> getAdGroup(
      int index, String oldName, String newName, String description) async {
    String fullUrl =
        "${baseURL}get_adgroups/?name=$oldName"; // Construct the full URL
    var token = await getToken(); // Fetch the token

    var response = await http.get(
      Uri.parse(fullUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //Errorhandling
    if (response.statusCode == 403) {
      throw Exception('User is not an admin of this ad group');
    } else if (response.statusCode != 200) {
      print(
          'Failed to get Ad: HTTP status ${response.statusCode}, ${response.body}');
      throw Exception('Failed to get Ad');
    }

    try {
      await fetchAdGroups(token!); // Refresh the list of AdGroups
    } catch (e) {
      print('Error updating Ads: $e');
    }
  }

  // Method to create an ad group
  static Future<dynamic> createAdGroup(
      String name, String description, var token) async {
    print('Creating new AdGroup'); // Debugging purposes
    try {
      String fullUrl = "${baseURL}create_adgroup/"; // Construct the full URL

      var response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': '$token',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Ad Group created successfully');
        await fetchAdGroups(token); // Refresh the list of AdGroups
      } else {
        throw Exception(
            'Failed to create Ad: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to create Ad Group: $e');
    }
  }

  static Future<dynamic> register(String url, Map<String, dynamic> data,
      {client = "default"}) async {
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      print(
          'Sending register request to $fullUrl with data $data'); // Debugging purposes

      final response = await client.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}'); // Debugging purposes
      print('Response body: ${response.body}'); // Debugging purposes

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to post data: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to post data: $e');
    }
  }

  @override
  notifyListeners();
}
