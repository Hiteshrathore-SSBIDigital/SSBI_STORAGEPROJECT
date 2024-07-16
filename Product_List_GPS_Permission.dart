import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:nehhdc_app/Screen/QRScan_Screen.dart';
import 'package:nehhdc_app/Screen/Add_Product.dart';

import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';
import 'package:quickalert/quickalert.dart';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;
import 'dart:io';

class Productlist_Screen extends StatefulWidget {
  const Productlist_Screen({Key? key}) : super(key: key);

  @override
  State<Productlist_Screen> createState() => _Productlist_ScreenState();
}

class _Productlist_ScreenState extends State<Productlist_Screen> {
  List<String> scannedQRCodes = [];
  List<Productstatus> productStatusList = [];

  @override
  void initState() {
    super.initState();
    checkGps();
    fetchData(context);
  }

  Future<bool> checkGps() async {
    bool serviceEnabled;
    LocationPermission permission;
    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showGpsDialog();
        return false;
      }

      // Check the current permission status
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission if denied
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle case when permission is denied forever
        _showPermissionDeniedDialog();
        return false;
      }

      // Handle additional edge cases specific to Android versions
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        if (serviceEnabled) {
          return true;
        } else {
          _showGpsDialog();
          return false;
        }
      }

      // Default case for safety
      _showPermissionDeniedDialog();
      return false;
    } catch (e) {
      print('Error checking GPS: $e');
      logError("GPS Location Error permission :$e");
      return false; // Return false in case of any error
    }
  }

  void _showGpsDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_off_outlined,
              color: Colors.grey,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'NEHHDC wants to use your location',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey),
            ),
          ],
        ),
        content: Text('Please enable GPS Location to continue.'),
        actions: <Widget>[
          TextButton(
            child: Text("Don't Allow"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Allow'),
            onPressed: () {
              Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Row(
          children: [
            Icon(
              Icons.location_off_outlined,
              color: Colors.grey,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Permission Denied',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey),
            ),
          ],
        ),
        content: Text(
            'Location permission is required to continue. Please allow access.'),
        actions: <Widget>[
          TextButton(
            child: Text("Don't Allow"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Allow'),
            onPressed: () async {
              await Geolocator.requestPermission();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product Status",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              fetchData(context);
            },
            icon: Icon(Icons.restart_alt_rounded),
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(ColorVal),
      ),
      body: productStatusList.isEmpty
          ? Center(
              child: Image.asset('assets/Images/Nodata.jpg'),
            )
          : ListView.builder(
              itemCount: productStatusList.length,
              itemBuilder: (BuildContext context, int index) {
                final Productstatus product = productStatusList[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildImageWidget(product.qrCodeValue),
                      ),
                      title: Text(
                        product.qrtest,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.weavername,
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "FABRIC",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          DateTime enddate = DateTime.now();
                          if (product.status == "End") {
                            _showSuccessMessage(
                                context, product.qrCodeValue, enddate);
                          } else if (product.status == "In Progress") {
                            staticverible.qrval = product.qrCodeValue;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProduct_Screen(
                                  qrVal: product.qrCodeValue,
                                  startDate: DateTime.now(),
                                  qrtext: product.qrtest,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width / 4.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: (product.status == "End")
                                ? Colors.green
                                : (product.status == "In Progress")
                                    ? Colors.amber
                                    : Colors.amber,
                          ),
                          child: Center(
                            child: Text(
                              product.status == "End"
                                  ? "End"
                                  : (product.status == "In Progress"
                                      ? "In Progress"
                                      : ""),
                              style: TextStyle(
                                color: product.status == "End"
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Divider(),
                    ),
                  ],
                );
              },
            ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(ColorVal),
        onPressed: () async {
          bool gpsEnabled = await checkGps();
          if (!gpsEnabled) {
            return;
          }

          final scannedQR = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => QRScan_Screen(),
            ),
          );
          if (scannedQR != null) {
            setState(() {
              scannedQRCodes.add(scannedQR);
            });
          }
        },
        child: Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showSuccessMessage(
      BuildContext context, String qrvalproduct, DateTime endDate) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      text: 'Finish this product',
      confirmBtnText: 'Yes',
      cancelBtnText: 'No',
      confirmBtnColor: Colors.green,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        uploadserviceenddata(
          context: context,
          qrcodevalue: qrvalproduct,
          enddate: endDate,
        );
        deleteImageFile(qrvalproduct);
      },
    );
  }

//  product end api
  Future<void> uploadserviceenddata(
      {required BuildContext context,
      required String qrcodevalue,
      required DateTime enddate}) async {
    try {
      plaesewaitmassage(context);
      final String devicesohApis =
          staticverible.temqr + '/UploadService.asmx/Updateprdenddate';

      var request = http.MultipartRequest('POST', Uri.parse(devicesohApis));

      request.fields['qrcodevalue'] = qrcodevalue;
      request.fields['enddate'] = enddate.toString();
      request.fields['status'] = 'End';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final document = xml.XmlDocument.parse(responseBody);
        final root = document.rootElement;

        if (root.name.local == 'string') {
          String message = root.text.trim();
          Map<String, dynamic> jsonResponse = json.decode(message);
          if (jsonResponse.containsKey("message")) {
            String responseMessage = jsonResponse["message"];
            if (responseMessage == "Data Added Successfully") {
              showMessageDialog(context, responseMessage);
              Navigator.of(context).pop();
              fetchData(context);
            } else {
              showRegisteredMessage(context, responseMessage);
              Navigator.of(context).pop();
            }
          }
        } else {
          throw FormatException('Unexpected format for response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        Navigator.of(context).pop();
        throw http.ClientException(
            'Failed to load Upload end data File  HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      logError('$e');
      Navigator.of(context).pop();
    }
  }

  void deleteImageFile(String qrCodeValue) {
    final String imagePath =
        '/storage/emulated/0/Android/media/SSBI_PROJECT/Scan_Images/$qrCodeValue.png';

    try {
      final File file = File(imagePath);
      if (file.existsSync()) {
        file.deleteSync();
        print('Image file deleted successfully');
      } else {
        print('Image file not found');
      }
    } catch (e) {
      print('Error deleting image file: $e');
    }
  }

  Future<void> fetchData(BuildContext context) async {
    try {
      await plaesewaitmassage(context);
      final String apiUrl =
          staticverible.temqr + "/UploadService.asmx/GetprdDatastatuswise";

      final Map<String, String> queryParams = {
        'state': staticverible.state,
        'district': staticverible.distric,
        'department': staticverible.department,
        'city': staticverible.city,
        'type': staticverible.type,
        'organization': staticverible.organization,
        'createdby': staticverible.username,
      };

      final Uri uri = Uri.parse(apiUrl);

      http.Response response = await http.post(uri, body: queryParams);

      if (response.statusCode == 200) {
        xml.XmlDocument responseData = xml.XmlDocument.parse(response.body);
        List<Productstatus> parsedData = parseXmlResponse(responseData);

        setState(() {
          productStatusList = parsedData;
        });
      } else {
        print("Request failed with status: ${response.statusCode}");
        print("Request failed with status: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
      logError('$e');
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> plaesewaitmassage(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (context.mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: "Please Wait",
        text: "Loading..",
      );
    }
  }

  List<Productstatus> parseXmlResponse(xml.XmlDocument responseData) {
    List<Productstatus> productStatusList = [];
    final jsonString = responseData.rootElement.text;
    final dynamic jsonData = json.decode(jsonString);

    if (jsonData is List) {
      // If jsonData is a List, proceed with parsing
      for (final item in jsonData) {
        if (item is Map<dynamic, dynamic>) {
          final productStatus =
              Productstatus.fromJson(item.cast<String, dynamic>());

          if (productStatus.status == "Scan") {
            productStatusList.add(productStatus.copyWith(status: "End"));
          } else if (productStatus.status == "Start") {
            productStatusList
                .add(productStatus.copyWith(status: "In Progress"));
          }

          // Print statements for debugging
          printProductStatus(productStatus);
        }
      }
    } else if (jsonData is Map) {
      // If jsonData is a Map, handle it accordingly
      final productStatus =
          Productstatus.fromJson(jsonData.cast<String, dynamic>());

      // Add custom logic based on status
      if (productStatus.status == "Scan") {
        productStatusList.add(productStatus.copyWith(status: "End"));
      } else if (productStatus.status == "Start") {
        productStatusList.add(productStatus.copyWith(status: "In Progress"));
      }

      // Print statements for debugging
      printProductStatus(productStatus);
    } else {
      // Handle unexpected JSON structure
      print("Unexpected JSON structure: $jsonData");
    }

    return productStatusList;
  }

  void printProductStatus(Productstatus productStatus) {
    print("Status: ${productStatus.status}");
    print("State: ${productStatus.state}");
    print("District: ${productStatus.district}");
    print("Department: ${productStatus.department}");
    print("Type: ${productStatus.type}");
    print("Organization: ${productStatus.organization}");
    print("City: ${productStatus.city}");
    print("Created By: ${productStatus.createdBy}");
    print("QR Code Value: ${productStatus.qrCodeValue}");
    print("QR image Value: ${productStatus.qrimage}");
    print("QR Text final: ${productStatus.qrtest}");
    print("Weaver Name: ${productStatus.weavername}");
    print("------------------------------------");
  }

  Widget _buildImageWidget(String qrCodeValue) {
    String imagePath = getLocalImagePath(qrCodeValue);
    if (imagePath != 'assets/Images/logo.png') {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
      );
    }
  }

  String getLocalImagePath(String qrCodeValue) {
    final String imagePath =
        '/storage/emulated/0/Android/media/SSBI_PROJECT/Scan_Images/$qrCodeValue.png';

    if (File(imagePath).existsSync()) {
      return imagePath;
    } else {
      return 'assets/Images/logo.png';
    }
  }
}

class Productstatus {
  final String status;
  final String state;
  final String district;
  final String department;
  final String type;
  final String organization;
  final String city;
  final String createdBy;
  final String qrCodeValue;
  final String qrimage;
  final String qrtest;
  final String weavername;

  Productstatus({
    required this.status,
    required this.state,
    required this.district,
    required this.department,
    required this.type,
    required this.organization,
    required this.city,
    required this.createdBy,
    required this.qrCodeValue,
    required this.qrimage,
    required this.qrtest,
    required this.weavername,
  });

  Productstatus copyWith({String? status}) {
    return Productstatus(
      status: status ?? this.status,
      state: this.state,
      district: this.district,
      department: this.department,
      type: this.type,
      organization: this.organization,
      city: this.city,
      createdBy: this.createdBy,
      qrCodeValue: this.qrCodeValue,
      qrimage: this.qrimage,
      qrtest: this.qrtest,
      weavername: this.weavername,
    );
  }

  factory Productstatus.fromJson(Map<String, dynamic> json) {
    return Productstatus(
      status: json['status'] ?? "",
      state: json['state'] ?? "",
      district: json['district'] ?? "",
      department: json['department'] ?? "",
      type: json['type'] ?? "",
      organization: json['organization'] ?? "",
      city: json['city'] ?? "",
      createdBy: json['createdby'] ?? "",
      qrCodeValue: json['qrcodevalue'] ?? "",
      qrimage: json['qrimage'] ?? "",
      qrtest: json['qrtextfinal'] ?? "",
      weavername: json['weavername'] ?? "",
    );
  }

  factory Productstatus.fromXml(xml.XmlElement element) {
    return Productstatus(
      status: element.findElements("status").first.text,
      state: element.findElements("state").first.text,
      district: element.findElements("district").first.text,
      department: element.findElements("department").first.text,
      type: element.findElements("type").first.text,
      organization: element.findElements("organization").first.text,
      city: element.findElements("city").first.text,
      createdBy: element.findElements("createdBy").first.text,
      qrCodeValue: element.findElements("qrCodeValue").first.text,
      qrimage: element.findElements("qrimage").first.text,
      qrtest: element.findElements("qrtextfinal").first.text,
      weavername: element.findElements("weavername").first.text,
    );
  }
}
