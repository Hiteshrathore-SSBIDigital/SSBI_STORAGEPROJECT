import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:intl/intl.dart';
import 'package:nehhdc_app/Setting_Screen/Directory_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Static_Verible';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class Device_Status extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothCharacteristic characteristic;
  final BluetoothService service;

  const Device_Status({
    Key? key,
    required this.device,
    required this.characteristic,
    required this.service,
  }) : super(key: key);

  @override
  _Device_StatusState createState() => _Device_StatusState();
}

class _Device_StatusState extends State<Device_Status> {
  late TextEditingController dateController = TextEditingController();
  ValueNotifier<int> rowCounter = ValueNotifier<int>(0);
  String datarow = '';
  bool alertShown = false;

  String hexDateTime = '';
  bool timervalidatde = false;

  String symbol = '';
  String filelog = '';
  String batteryStatusMessage = '';
  bool isConnected = true;
  String deviceVersionMessage = '';
  List<String> storedData = [];
  late File SohdataFile;
  late File devicedataFile;
  Color batteryColor = Colors.deepPurple;
  String batteryupdate = '';
  String lastearsedata = 'Reading...';
  String custval = 'Reading...';
  String custservice = 'Reading...';
  String apptimer = 'Reading...';
  String updatedDateTime = 'Reading...';
  String readaccel = 'Reading...';
  String errormassage = '';
  String readgyro = 'Reading...';
  String readeulr = 'Reading...';
  String numreading = 'Reading...';
  String stockcounterval = 'Reading...';
  bool isSending = false;
  int numberOfProperReadings = 0;
  double progress = 0.0;
  int dollarCount = 0;
  @override
  void initState() {
    super.initState();
    readBatteryStatus(widget.service);
    readDeviceVersion(widget.service);
    Numberofreading(widget.service);
    apptimemethod(widget.service);
//   fetchDataAndUpdateState(widget.service);
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> readDeviceVersion(BluetoothService customService) async {
    try {
      if (customService != '') {
        BluetoothCharacteristic customCharacteristic =
            customService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString().toUpperCase() ==
              'F3641403-00B0-4240-BA50-05CA45BF8ABC',
          orElse: () =>
              throw Exception('Device version characteristic not found'),
        );

        if (customCharacteristic != '') {
          await Future.delayed(Duration(seconds: 1));

          List<int> value = await customCharacteristic.read();

          if (value.isNotEmpty) {
            String deviceVersionString = String.fromCharCodes(value);

            deviceVersionString = deviceVersionString.replaceAll(
                RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');

            if (!deviceVersionString.startsWith('V')) {
              deviceVersionString = 'V$deviceVersionString';
            }

            setState(() {
              deviceVersionMessage = deviceVersionString;
            });
          } else {
            setState(() {
              print("Unknown");
            });
          }
        } else {
          setState(() {
            print("Device version characteristic not found");
          });
        }
      } else {
        setState(() {
          print("Custom service with UUID not found");
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        print('Error reading: ${e.message}');
      });
    } catch (e) {
      setState(() {
        print('Error reading: ${e}');
      });
    }
  }

  Future<void> Numberofreading(BluetoothService customService) async {
    try {
      if (customService != '') {
        BluetoothCharacteristic customCharacteristic =
            customService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString().toUpperCase() ==
              'F364140A-00B0-4240-BA50-05CA45BF8ABC',
          orElse: () =>
              throw Exception('Number of reading characteristic not found'),
        );

        if (customCharacteristic != '') {
          await Future.delayed(Duration(seconds: 1));
          List<int> value = await customCharacteristic.read();
          if (value.isNotEmpty) {
            String hexString = value
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join('');

            String firstTwoBytes = hexString.substring(0, 2);
            int decimalValue = int.parse(firstTwoBytes, radix: 16);
            setState(() {
              numreading = '$decimalValue';
              print('$decimalValue');
            });
            numberOfProperReadings++;
          } else {
            setState(() {
              print("Unknown");
            });
          }
        } else {
          setState(() {
            print("Number of reading characteristic not found");
          });
        }
      } else {
        setState(() {
          print("Custom service with UUID not found");
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        print('${e.message}');
      });
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  Future<void> stockcountermethod(BluetoothService customService) async {
    try {
      if (customService != '') {
        BluetoothCharacteristic customCharacteristic =
            customService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString().toUpperCase() ==
              'F364140C-00B0-4240-BA50-05CA45BF8ABC',
          orElse: () =>
              throw Exception('Number of reading characteristic not found'),
        );

        if (customCharacteristic != '') {
          await Future.delayed(Duration(seconds: 1));
          List<int> value = await customCharacteristic.read();
          if (value.isNotEmpty) {
            String hexString = value
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join('');

            String firstTwoBytes = hexString.substring(0, 2);
            int decimalValue = int.parse(firstTwoBytes, radix: 16);
            setState(() {
              stockcounterval = '$decimalValue';
            });
          } else {
            setState(() {
              print("Unknown");
            });
          }
        } else {
          setState(() {
            print("Number of reading characteristic not found");
          });
        }
      } else {
        setState(() {
          print("Custom service with UUID not found");
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        print('${e.message}');
      });
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  Future<void> apptimemethod(BluetoothService customService) async {
    try {
      if (customService != '') {
        BluetoothCharacteristic customCharacteristic =
            customService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString().toUpperCase() ==
              'F3641404-00B0-4240-BA50-05CA45BF8ABC',
          orElse: () =>
              throw Exception('Application timer characteristic not found'),
        );

        if (customCharacteristic != '') {
          List<int> value = await customCharacteristic.read();
          if (value.isNotEmpty) {
            String hexString = value
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join('');

            updateTimeFromHexadecimal(hexString);
          } else {
            setState(() {
              print("Unknown");
            });
          }
        } else {
          setState(() {
            print("Application timer characteristic not found");
          });
        }
      } else {
        setState(() {
          print("Custom service with UUID not found");
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        print('${e.message}');
      });
    } catch (e) {
      setState(() {
        print('${e}');
      });
    }
  }

  void updateTimeFromHexadecimal(String hexValue) {
    hexValue = hexValue.replaceAll(RegExp(r'^0+|0+$'), '');
    int seconds = int.parse(hexValue, radix: 16);

    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    String formattedTime;

    if (minutes > 0) {
      formattedTime =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} Minutes';
    } else {
      formattedTime =
          '${hours.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')} Second';
    }

    print('Formatted time: $formattedTime');
    setState(() {
      apptimer = formattedTime;
      print(apptimer);
      print(formattedTime);
    });
  }

  Future<void> resetDevice(BluetoothDevice device) async {
    plaesewaitmassage(context);

    try {
      bool isConnected =
          await device.state.first == BluetoothDeviceState.connected;
      if (!isConnected) {
        await device.connect();
      }
      List<BluetoothService> services = await device.discoverServices();
      BluetoothService desiredService = services.firstWhere(
        (service) => service.uuid == widget.characteristic.serviceUuid,
        orElse: () => throw Exception('Service not found'),
      );
      BluetoothCharacteristic desiredCharacteristic =
          desiredService.characteristics.firstWhere(
        (characteristic) => characteristic.uuid == widget.characteristic.uuid,
        orElse: () => throw Exception('Characteristic not found'),
      );
      await Future.delayed(Duration(seconds: 3));
      await desiredCharacteristic.write([0x02]);
      Navigator.of(context).pop();
      print('Stored data Rest device successfully.');
    } catch (e) {
      print('Error erasing stored data: $e');
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> readCharacteristics(BluetoothService customService) async {
    try {
      if (customService != '') {
        readaccel = await readCharacteristic(
          customService,
          'F3641407-00B0-4240-BA50-05CA45BF8ABC',
          'Device version characteristic not found',
          'Error reading',
        );

        // Read gyro method
        readgyro = await readCharacteristic(
          customService,
          'F3641408-00B0-4240-BA50-05CA45BF8ABC',
          'Gyro characteristic not found',
          'Error reading gyro',
        );

        // Read eulr method
        readeulr = await readCharacteristic(
          customService,
          'F3641409-00B0-4240-BA50-05CA45BF8ABC',
          'Datetime characteristic not found',
          'Error reading eulr',
        );
        // Update date time method
        updatedDateTime = await readCharacteristic(
          customService,
          'F3641406-00B0-4240-BA50-05CA45BF8ABC',
          'Device version characteristic not found',
          'Error reading device version',
        );

        // Last erase method
        lastearsedata = await readCharacteristic(
          customService,
          'F364140B-00B0-4240-BA50-05CA45BF8ABC',
          'Device version characteristic not found',
          'Error reading device version',
        );
      } else {
        setState(() {
          print("Custom service with UUID not found");
        });
      }
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

  Future<String> readCharacteristic(
    BluetoothService customService,
    String characteristicUUID,
    String notFoundText,
    String errorText,
  ) async {
    try {
      if (customService != '') {
        BluetoothCharacteristic customCharacteristic =
            customService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString().toUpperCase() ==
              characteristicUUID.toUpperCase(),
          orElse: () => throw Exception(notFoundText),
        );

        if (customCharacteristic != '') {
          await Future.delayed(Duration(seconds: 1));
          List<int> value = await customCharacteristic.read();
          if (value.isNotEmpty) {
            String status = removeExtraSpaces(String.fromCharCodes(value));
            return status;
          } else {
            return 'Unknown';
          }
        } else {
          return notFoundText;
        }
      } else {
        return 'Custom service with UUID not found';
      }
    } on PlatformException catch (e) {
      return '$errorText ${e.message}';
    } catch (e) {
      return '$errorText $e';
    }
  }

  String removeExtraSpaces(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void fetchDataAndUpdateState(BluetoothService customService) async {
    try {
      await readCharacteristics(widget.service);
      await stockcountermethod(widget.service);
      await Numberofreading(widget.service);
      await apptimemethod(widget.service);
    } catch (e) {
      setState(() {
        print('Error fetching data: $e');
      });
    } finally {
      setState(() {});
    }
  }

  void disconnectDevice() async {
    try {
      await widget.device.disconnect();
      setState(() {
        isConnected = false;
      });
    } catch (e) {
      print('Error disconnecting device: $e');
    }
  }

  Future<void> readBatteryStatus(BluetoothService customService) async {
    try {
      if (customService != '') {
        BluetoothCharacteristic customCharacteristic =
            customService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString().toUpperCase() ==
              'F3641402-00B0-4240-BA50-05CA45BF8ABC',
          orElse: () =>
              throw Exception('Custom characteristic with UUID not found'),
        );

        if (customCharacteristic != '') {
          List<int> value = await customCharacteristic.read();
          if (value.isNotEmpty) {
            int batteryLevelHex = value[0];
            int batteryLevelDecimal = (batteryLevelHex & 0xFF);
            batteryLevelDecimal =
                batteryLevelDecimal > 100 ? 100 : batteryLevelDecimal;

            setState(() {
              batteryStatusMessage = 'Battery Level: $batteryLevelDecimal%';
              batteryupdate = '$batteryLevelDecimal%';
              batteryColor = _getBatteryLevelColor(batteryLevelDecimal);
            });
          } else {
            print('Battery Level: Unknown');
          }
        } else {
          print('Custom characteristic with UUID not found');
        }
      } else {
        print('Custom service with UUID not found');
      }
    } catch (e) {
      print('Error reading battery status: $e');
    }
  }

  void showCustomAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Column(
            children: [
              Center(
                child: Text(
                  'Device Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey),
                ),
              ),
              Divider()
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("1. Battery Status = $batteryupdate"),
                Text("2. Firmware Version Status = $deviceVersionMessage"),
                Text("3. App Timer Status = $apptimer"),
                Text("4. Device MAC Status = ${widget.service.deviceId}"),
                Text("5. Date Time Update Status = $updatedDateTime"),
                Text("6. Read ACCEL Status = $readaccel"),
                Text("7. Read Gyro Status = $readgyro"),
                Text("8. Read Eulr Angl Status = $readeulr"),
                Text("9. Number of Reading Status = $numreading"),
                Text("10. Last Erased Status = $lastearsedata"),
                Text("11. Stock Counter Status = $stockcounterval"),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),
                InkWell(
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(ColorVal),
                      ),
                      child: Center(
                        child: Text(
                          "Close",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  MyTime pickedTime = MyTime();
  Duration selectedDuration = Duration(hours: 0, minutes: 0, seconds: 0);
  void _showTimerPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: CupertinoColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Text("DONE"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      plaesewaitmassage(context);
                      Future.delayed(Duration(seconds: 2), () {
                        setState(() {
                          updateTimehexacode(pickedTime);
                        });
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: selectedDuration,
                  onTimerDurationChanged: (Duration duration) {
                    setState(() {
                      selectedDuration = duration;
                      pickedTime = MyTime(
                        hour: duration.inHours,
                        minute: duration.inMinutes.remainder(60),
                        second: duration.inSeconds.remainder(60),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateTimehexacode(MyTime pickedTime) {
    int hours = pickedTime.hour;
    int minutes = pickedTime.minute;
    int seconds = pickedTime.second;

    int totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

    String hexValue = totalSeconds.toRadixString(16).toUpperCase();

    // Check if only seconds are provided (hours and minutes are zero)
    if (hours == 0 && minutes == 0 && seconds != 0) {
      hexValue += '000000';
    } else {
      hexValue += '0000';
    }

    dateController.text = hexValue;

    if (pickedTime != '') {
      setState(() {
        timermethod(widget.service);
      });
    }
  }

  Future<void> timermethod(BluetoothService customService) async {
    try {
      BluetoothCharacteristic desiredCharacteristic =
          customService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid.toString().toUpperCase() ==
            'F3641404-00B0-4240-BA50-05CA45BF8ABC',
        orElse: () => throw Exception('Characteristic with UUID not found'),
      );

      print("Timer Hexavalue ${dateController.text}");

      List<int> data = hexStringToBytes(dateController.text);

      await desiredCharacteristic.write(data);
      print("Data sent successfully");

      showMessageDialog(context, "Data sent successfully");
      print("Data sent successfully");

      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      print('Error: $e');
      logError("Device timer error $e");
      Navigator.pop(context);
    }
  }

  Future<void> Datetimemethod(BluetoothService customService) async {
    try {
      await Future.delayed(Duration(seconds: 2));

      BluetoothCharacteristic desiredCharacteristic =
          customService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid.toString().toUpperCase() ==
            'F3641406-00B0-4240-BA50-05CA45BF8ABC',
        orElse: () => throw Exception('Characteristic with UUID not found'),
      );

      String hexDateTime = getCurrentDateTimeInHexFormat();

      List<int> data = hexStringToBytes(hexDateTime);

      await desiredCharacteristic.write(data);

      showMessageDialog(context, "Date update successfully");
      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
    }
  }

  String getCurrentDateTimeInHexFormat() {
    DateTime now = DateTime.now();

    int day = now.day;
    int month = now.month;
    int year = now.year % 100;
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;

    String hexDay = day.toRadixString(16).padLeft(2, '0');
    String hexMonth = month.toRadixString(16).padLeft(2, '0');
    String hexYear = year.toRadixString(16).padLeft(2, '0');
    String hexHour = hour.toRadixString(16).padLeft(2, '0');
    String hexMinute = minute.toRadixString(16).padLeft(2, '0');
    String hexSecond = second.toRadixString(16).padLeft(2, '0');

    hexDateTime = '$hexDay$hexMonth$hexYear$hexHour$hexMinute$hexSecond';

    return hexDateTime.toUpperCase();
  }

  List<int> hexStringToBytes(String hex) {
    hex = hex.replaceAll(" ", "");

    if (!hex.startsWith('0')) {
      hex = '0' + hex;
    }

    print("Final Hex Value: $hex");

    List<int> bytes = [];

    for (int i = 0; i < hex.length; i += 2) {
      // Check if there's enough room for two characters
      if (i + 2 <= hex.length) {
        String byteStr = hex.substring(i, i + 2);
        int byteVal = int.parse(byteStr, radix: 16);
        bytes.add(byteVal);
      } else {
        // Handle case where there's only one character left (odd length hex)
        String byteStr = hex.substring(i, i + 1); // Take one character
        int byteVal = int.parse(byteStr, radix: 16);
        bytes.add(byteVal);
      }
    }
    return bytes;
  }

  Future<File> statusInsertFile(String deviceid, List<String?> textData) async {
    try {
      String sanitizedDeviceId = deviceid.replaceAll(':', '');

      Directory? directory = await getAndroidMediaDirectory();
      if (directory != null) {
        Directory deviceDataDirectory =
            Directory('${directory.path}/DeviceData');
        if (!(await deviceDataDirectory.exists())) {
          await deviceDataDirectory.create();
        }

        String filename = 'SOH' +
            '_' +
            sanitizedDeviceId +
            '_' +
            DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now()) +
            '.txt';

        String filePath = '${deviceDataDirectory.path}/$filename';

        SohdataFile = File(filePath);
        RandomAccessFile raf = SohdataFile.openSync(mode: FileMode.write);

        raf.writeStringSync('Run Date Time: ${DateTime.now()}\n');
        raf.writeStringSync('Device ID: $deviceid\n\n');

        textData
            .where((text) => text != null)
            .map((text) => text!.trim())
            .map((text) => text.trim())
            .forEach((text) {
          raf.writeStringSync('$text\n');
        });

        await raf.close();

        print('Data file initialized successfully: $filename');
        showCustomAlertDialog(context);
        return SohdataFile;
      } else {
        throw Exception('Error: External storage directory is null');
      }
    } catch (e) {
      throw Exception('Error initializing data file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              title: Text(
                'Do you want to exit?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              content: Container(
                constraints: BoxConstraints(
                  minHeight: 45,
                  maxHeight: 45,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Some connections are still open.Click',
                    ),
                    Text(
                      'YES to close all and exit.',
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        disconnectDevice();
                      },
                      child: Text('YES'),
                    ),
                  ],
                )
              ],
            ),
          );
          return confirm;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              isConnected
                  ? 'Connected to: ${widget.device.name}'
                  : 'Not Connected',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Color(ColorVal),
            actions: [
              TextButton(
                onPressed: () {
                  disconnectDevice();
                },
                child: Text(
                  isConnected ? 'Disconnect' : 'Connect',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1,
                    child: CircularPercentIndicator(
                      animation: true,
                      animationDuration: 100,
                      radius: 80,
                      lineWidth: 15,
                      center: Text(
                        batteryStatusMessage,
                        style: TextStyle(fontSize: 13),
                      ),
                      percent: _getBatteryPercent(),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: batteryColor,
                      backgroundColor: Colors.deepPurple.shade200,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                "Device version",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              deviceVersionMessage,
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Download Data",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 10,
                              ),
                              Container(
                                  height: 30,
                                  child: Image.asset(
                                      'assets/Images/download_data.gif'))
                            ],
                          ),
                        ),
                        onTap: () async {
                          bool isDeviceConnected =
                              await widget.device.state.first ==
                                  BluetoothDeviceState.connected;
                          String deviceId = widget.device.id.toString();
                          if (isDeviceConnected) {
                            retrieveStoredData(context, deviceId);
                          } else {
                            showMessageDialog(context,
                                "Please connect to the device via Bluetooth.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Please connect to the device via Bluetooth.',
                                ),
                              ),
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              // second
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Device SOH",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 10,
                              ),
                              Container(
                                  height: 30,
                                  child: Image.asset('assets/Images/info.gif'))
                            ],
                          ),
                        ),
                        onTap: () async {
                          bool isDeviceConnected =
                              await widget.device.state.first ==
                                  BluetoothDeviceState.connected;
                          // String deviceId = widget.device.id.toString();
                          if (isDeviceConnected) {
                            plaesewaitdevicereport(context);
                            fetchDataAndUpdateState(widget.service);
                            try {
                              await Future.delayed(Duration(seconds: 13));

                              Navigator.of(context).pop();

                              bool isDeviceConnected =
                                  await widget.device.state.first ==
                                      BluetoothDeviceState.connected;

                              if (isDeviceConnected) {
                                List<String> textData = [
                                  '1.Battery Status = $batteryupdate',
                                  '2.Firmware Version Status = $deviceVersionMessage',
                                  '3.App Timer Status = $apptimer',
                                  '4.Device MAC Status = ${widget.service.deviceId}',
                                  '5.Date Time Update Status = $updatedDateTime',
                                  '9.Read ACCEL Status = $readaccel',
                                  '7.Read Gyro Status = $readgyro',
                                  '8.Read Eulr Angl Status = $readeulr',
                                  '9.Number of Reading Status = $numreading',
                                  '10.Last Erased Status = $lastearsedata',
                                  '11.Stock Counter Status = $stockcounterval',
                                ];

                                textData = textData.map((string) {
                                  List<int> bytes = string.toString().codeUnits;
                                  String decodedString = utf8.decode(bytes);

                                  String cleanedString = decodedString
                                      .replaceAll(RegExp(r'[^ -~]+'), '');

                                  return cleanedString;
                                }).toList();

                                String deviceId =
                                    widget.service.deviceId.toString();
                                SohdataFile =
                                    await statusInsertFile(deviceId, textData);
                                uploadSOHFile(context);
                              } else {
                                showMessageDialog(context,
                                    "Please connect to the device via Bluetooth.");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        'Please connect to the device via Bluetooth.'),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Handle any errors
                              print("Error: $e");
                              Navigator.of(context)
                                  .pop(); // Dismiss the dialog if an error occurs
                            }
                          }
                        }),
                    InkWell(
                      child: Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width / 2.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                "Date Sync",
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                              width: 10,
                            ),
                            Container(
                                height: 30,
                                child: Image.asset('assets/Images/sync.gif'))
                          ],
                        ),
                      ),
                      onTap: () async {
                        bool isDeviceConnected =
                            await widget.device.state.first ==
                                BluetoothDeviceState.connected;
                        //    String deviceId = widget.device.id.toString();
                        if (isDeviceConnected) {
                          getCurrentDateTimeInHexFormat();
                          plaesewaitmassage(context);
                          Datetimemethod(widget.service);
                        } else {
                          showMessageDialog(context,
                              "Please connect to the device via Bluetooth.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Please connect to the device via Bluetooth.',
                              ),
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Device Reset",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 10,
                              ),
                              Container(
                                  height: 30,
                                  child: Image.asset('assets/Images/reset.gif'))
                            ],
                          ),
                        ),
                        onTap: () async {
                          bool isDeviceConnected =
                              await widget.device.state.first ==
                                  BluetoothDeviceState.connected;
                          //     String deviceId = widget.device.id.toString();
                          if (isDeviceConnected) {
                            resetDevice(widget.device);
                          } else {
                            showMessageDialog(context,
                                "Please connect to the device via Bluetooth.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Please connect to the device via Bluetooth.',
                                ),
                              ),
                            );
                          }
                        }),
                    InkWell(
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Set Timer",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 10,
                              ),
                              Container(
                                  height: 30,
                                  child: Image.asset('assets/Images/timer.gif'))
                            ],
                          ),
                        ),
                        onTap: () async {
                          bool isDeviceConnected =
                              await widget.device.state.first ==
                                  BluetoothDeviceState.connected;
                          //     String deviceId = widget.device.id.toString();
                          if (isDeviceConnected) {
                            _showTimerPicker(context);
                            //  openTimePicker(context);
                          } else {
                            showMessageDialog(context,
                                "Please connect to the device via Bluetooth.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Please connect to the device via Bluetooth.',
                                ),
                              ),
                            );
                          }
                        }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Earse Data",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 10,
                              ),
                              Container(
                                  height: 30,
                                  child: Image.asset('assets/Images/bin.gif'))
                            ],
                          ),
                        ),
                        onTap: () async {
                          bool isDeviceConnected =
                              await widget.device.state.first ==
                                  BluetoothDeviceState.connected;
                          // String deviceId = widget.device.id.toString();
                          if (isDeviceConnected) {
                            _showPasswordDialog(context);
                          } else {
                            showMessageDialog(context,
                                "Please connect to the device via Bluetooth.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Please connect to the device via Bluetooth.',
                                ),
                              ),
                            );
                          }
                        }),
                    InkWell(
                        child: Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Device Update",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                                width: 10,
                              ),
                              Container(
                                  height: 30,
                                  child:
                                      Image.asset('assets/Images/update.gif'))
                            ],
                          ),
                        ),
                        onTap: () async {
                          bool isDeviceConnected =
                              await widget.device.state.first ==
                                  BluetoothDeviceState.connected;
                          //  String deviceId = widget.device.id.toString();
                          if (isDeviceConnected) {
                            //    selectupdateFile(context);
                          } else {
                            showMessageDialog(context,
                                "Please connect to the device via Bluetooth.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Please connect to the device via Bluetooth.',
                                ),
                              ),
                            );
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        ));
  }

// Sensor device update
//   Future<void> selectupdateFile(BuildContext context) async {
//     try {
//     //  FilePickerResult? result = await FilePicker.platform.pickFiles(
//    //     type: FileType.custom,
//  //       allowedExtensions: ['zip'],
//   //    );

//       if (result != null && result.files.isNotEmpty) {
//         String filePath = result.files.single.path!;
//         if (filePath.endsWith('.zip')) {
//           print("Selected zip file path: $filePath");
//         } else {
//           _showInvalidFileDialog(context);
//         }
//       } else {
//         print("File selection canceled");
//       }
//     } catch (e) {
//       print("Error picking file: $e");
//     }
//   }

  void _showInvalidFileDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Invalid File",
      text: "Please select a valid update zip file",
    );
  }

  double _getBatteryPercent() {
    String batteryLevelString =
        batteryStatusMessage.replaceAll(RegExp(r'[^0-9]'), '');
    int batteryLevel = int.tryParse(batteryLevelString) ?? 0;

    batteryLevel = batteryLevel.clamp(0, 100);

    double batteryPercent = batteryLevel / 100.0;

    return batteryPercent;
  }

  Color _getBatteryLevelColor(int batteryLevel) {
    if (batteryLevel >= 70) {
      return Colors.green;
    } else if (batteryLevel >= 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void plaesewaitmassagedata(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            title: Text(
              "Please Wait",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            content: Container(
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text("Loading.."),
                  )
                ],
              ),
            ));
      },
    );
  }

  Future<File> initializeDataFile(String deviceid) async {
    try {
      String sanitizedDeviceId = deviceid.replaceAll(':', '');

      Directory? directory = await getAndroidMediaDirectory();
      if (directory != null) {
        Directory deviceDataDirectory =
            Directory('${directory.path}/DeviceData');
        if (!(await deviceDataDirectory.exists())) {
          await deviceDataDirectory.create();
        }
        String filename = sanitizedDeviceId +
            '_' +
            DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        devicedataFile = File('${deviceDataDirectory.path}/$filename.csv');

        print('Data file initialized successfully: $filename');

        // Return the file
        return devicedataFile;
      } else {
        throw Exception('Error: External storage directory is null');
      }
    } catch (e) {
      throw Exception('Error initializing data file: $e');
    }
  }

  Future<File> initializeDataFile_logs(String deviceid) async {
    try {
      // Remove colons from the deviceid
      String sanitizedDeviceId = deviceid.replaceAll(':', '');

      Directory? directory = await getAndroidMediaDirectory();
      if (directory != null) {
        Directory deviceDataDirectory =
            Directory('${directory.path}/DeviceData');
        if (!(await deviceDataDirectory.exists())) {
          await deviceDataDirectory.create();
        }
        String filename = 'Log_' +
            sanitizedDeviceId +
            '_' +
            DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        devicedataFile = File('${deviceDataDirectory.path}/$filename.csv');

        print('Data file initialized successfully: $filename');

        // Return the file
        return devicedataFile;
      } else {
        throw Exception('Error: External storage directory is null');
      }
    } catch (e) {
      throw Exception('Error initializing data file: $e');
    }
  }

  bool isDummyData(String data) {
    return data == "ÿÿÿÿÿÿÿÿÿÿÿÿ" || data.startsWith("ÿÿÿÿÿÿ");
  }

  // Future<void> retrieveStoredData(BuildContext context, String deviceid) async {
  //   try {
  //     showPleaseWaitDialog(context, rowCounter);

  //     File dataFile = await initializeDataFile(deviceid);
  //     // File dataFile_logs = await initializeDataFile_logs(deviceid);
  //     // if (dataFile_logs == null) {
  //     //   print("Log file not generated");
  //     // }

  //     if (dataFile != '') {
  //       BluetoothDevice desiredDevice = widget.device;

  //       bool isConnected =
  //           await desiredDevice.state.first == BluetoothDeviceState.connected;

  //       if (!isConnected) {
  //         await desiredDevice.connect();
  //       }

  //       List<BluetoothService> services =
  //           await desiredDevice.discoverServices();

  //       BluetoothService desiredService = services.firstWhere(
  //         (service) =>
  //             service.uuid.toString() ==
  //             widget.characteristic.serviceUuid.toString(),
  //         orElse: () => throw Exception('Service not found'),
  //       );

  //       BluetoothCharacteristic desiredCharacteristic =
  //           desiredService.characteristics.firstWhere(
  //         (characteristic) =>
  //             characteristic.uuid.toString() ==
  //             widget.characteristic.uuid.toString(),
  //         orElse: () => throw Exception('Characteristic not found'),
  //       );

  //       await desiredCharacteristic.setNotifyValue(true);

  //       int rowCount = 0;
  //       bool dataFound = false;
  //       bool isFirstIteration = true;
  //       int notfoundcount = 0;
  //       int dollarCount = 0;
  //       await for (List<int>? value in desiredCharacteristic.value) {
  //         if (isFirstIteration && value == null) {
  //           break;
  //         }

  //         isFirstIteration = false;
  //         print(value);

  //         if (value != null) {
  //           String newData = String.fromCharCodes(value);
  //           newData = processNewData(newData);
  //           print(newData);

  //           if (newData.isNotEmpty && newData.trim() != "") {
  //             if (newData == "ÿÿÿÿÿÿ" || newData.startsWith("ÿÿÿÿÿÿ")) {
  //               notfoundcount++;
  //             } else {
  //               notfoundcount = 0;
  //             }
  //             if (notfoundcount >= 3) {
  //               await desiredCharacteristic.setNotifyValue(false);
  //               if (!dataFound) {
  //                 Navigator.of(context).pop();
  //                 QuickAlert.show(
  //                   context: context,
  //                   type: QuickAlertType.warning,
  //                   title: "Data Not Found",
  //                   text: "There is no data available on the device.",
  //                 );
  //               } else {
  //                 Navigator.of(context).pop();
  //                 QuickAlert.show(
  //                   context: context,
  //                   type: QuickAlertType.success,
  //                   title: "Success",
  //                   text: "Data Added Successfully",
  //                   onConfirmBtnTap: () {
  //                     Navigator.of(context).pop();
  //                     uploadFileData(context);
  //                   },
  //                 );
  //               }
  //               break;
  //             } else {
  //               if (newData.trim() != "") {
  //                 if (newData == "ÿÿÿÿÿÿ" || newData.startsWith("ÿÿÿÿÿÿ")) {
  //                 } else {
  //                   await dataFile.writeAsString(newData,
  //                       mode: FileMode.append);
  //                   dataFound = true;
  //                 }
  //               }
  //             }
  //             rowCount++;
  //             rowCounter.value = rowCount;
  //             print(rowCount);
  //             print("Data Record Number $dollarCount");
  //           }
  //         }
  //       }
  //       print("Data Record Number $dollarCount");
  //     }
  //   } catch (e) {
  //     print('Error retrieving data: $e');
  //   }
  // }

  void showPleaseWaitDialog(
      BuildContext context, ValueNotifier<int> rowCounter) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(
            "Please Wait",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          content: ValueListenableBuilder<int>(
            valueListenable: rowCounter,
            builder: (context, value, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green[500]!),
                    backgroundColor: Colors.grey[200],
                    strokeWidth: 5.0,
                    strokeCap: StrokeCap.round,
                  ),
                  SizedBox(width: 20),
                  Text("Rows processed: $dollarCount"),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> retrieveStoredData(BuildContext context, String deviceid) async {
    try {
      showPleaseWaitDialog(context, rowCounter);

      File dataFile = await initializeDataFile(deviceid);

      if (dataFile != '') {
        BluetoothDevice desiredDevice = widget.device;

        bool isConnected =
            await desiredDevice.state.first == BluetoothDeviceState.connected;

        if (!isConnected) {
          await desiredDevice.connect();
        }

        List<BluetoothService> services =
            await desiredDevice.discoverServices();

        BluetoothService desiredService = services.firstWhere(
          (service) =>
              service.uuid.toString() ==
              widget.characteristic.serviceUuid.toString(),
          orElse: () => throw Exception('Service not found'),
        );

        BluetoothCharacteristic desiredCharacteristic =
            desiredService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid.toString() ==
              widget.characteristic.uuid.toString(),
          orElse: () => throw Exception('Characteristic not found'),
        );

        await desiredCharacteristic.setNotifyValue(true);

        int rowCount = 0;
        bool dataFound = false;
        bool isFirstIteration = true;
        int notfoundcount = 0;
        dollarCount = 0;
        await for (List<int>? value in desiredCharacteristic.value) {
          if (isFirstIteration && value == null) {
            break;
          }

          isFirstIteration = false;
          print(value);

          if (value != null) {
            String newData = String.fromCharCodes(value);
            newData = processNewData(newData);
            print(newData);

            // Count the number of dollar signs in the new data
            dollarCount += newData.split('\$').length - 1;

            // Ensure new $ data starts on a new line
            List<String> rows = newData.split('\n');

            for (String row in rows) {
              if (row.startsWith('\$') && row.endsWith('#')) {
                await dataFile.writeAsString('$row\n', mode: FileMode.append);
                rowCount++;
              }
            }

            if (newData.isNotEmpty && newData.trim() != "") {
              if (newData == "ÿÿÿÿÿÿ" || newData.startsWith("ÿÿÿÿÿÿ")) {
                notfoundcount++;
              } else {
                notfoundcount = 0;
              }
              if (notfoundcount >= 3) {
                await desiredCharacteristic.setNotifyValue(false);
                if (!dataFound) {
                  Navigator.of(context).pop();
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: "Data Not Found",
                    text: "There is no data available on the device.",
                  );
                } else {
                  Navigator.of(context).pop();
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    title: "Success",
                    text: "Data Added Successfully",
                    onConfirmBtnTap: () {
                      Navigator.of(context).pop();
                      uploadFileData(context);
                    },
                  );
                }
                break;
              } else {
                if (newData.trim() != "") {
                  if (newData == "ÿÿÿÿÿÿ" || newData.startsWith("ÿÿÿÿÿÿ")) {
                  } else {
                    await dataFile.writeAsString(newData,
                        mode: FileMode.append);
                    dataFound = true;
                  }
                }
              }
              rowCount++;
              rowCounter.value = rowCount;
              print(rowCount);
              print("Data Record Number $dollarCount");
            }
          }
        }
        print("Data Record Number $dollarCount");
      }
    } catch (e) {
      print('Error retrieving data: $e');
    }
  }

  Future<void> eraseStoredData(BluetoothDevice device) async {
    try {
      plaesewaitmassageprocess(context);
      bool isConnected =
          await device.state.first == BluetoothDeviceState.connected;
      if (!isConnected) {
        await device.connect();
      }

      List<BluetoothService> services = await device.discoverServices();
      BluetoothService desiredService = services.firstWhere(
        (service) => service.uuid == widget.characteristic.serviceUuid,
        orElse: () => throw Exception('Service not found'),
      );
      BluetoothCharacteristic desiredCharacteristic =
          desiredService.characteristics.firstWhere(
        (characteristic) => characteristic.uuid == widget.characteristic.uuid,
        orElse: () => throw Exception('Characteristic not found'),
      );
      await desiredCharacteristic.write([0x01]);
      await Future.delayed(Duration(seconds: 5));
      print('Stored data erased successfully.');
      readThenWrite(widget.service, widget.device);
    } catch (e) {
      print('Error erasing stored data: $e');
    }
  }

  String hexval = '07080000';
  Future<void> readThenWrite(
      BluetoothService customService, BluetoothDevice device) async {
    try {
      BluetoothCharacteristic desiredCharacteristic =
          customService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid.toString().toUpperCase() ==
            'F3641404-00B0-4240-BA50-05CA45BF8ABC',
        orElse: () => throw Exception('Characteristic with UUID not found'),
      );
      List<int> data = hexStringToBytes(hexval);
      await desiredCharacteristic.write(data);

      Navigator.pop(context);
      CompletedprocessMASSAGE(context);
      print("Reconnected to the device");

      showMessageDialog(context, "All process done");
    } catch (e) {
      print('Error: $e');
    }
  }

  String processNewData(String newData) {
    if (newData == '' || newData.trim().isEmpty) {
      return newData;
    }
    if (newData.trim() == "ÿÿÿÿÿÿÿÿÿÿÿÿ") {
      return newData;
    }
    if (RegExp(r"R'[^ -~]+'").hasMatch(newData) ||
        RegExp(r"R'[^ -~]+'$").hasMatch(newData)) {
      return '';
    }

    int dollarCIndex = newData.indexOf('\$c');
    if (dollarCIndex != -1) {
      newData = newData.substring(dollarCIndex);
    }

    newData = newData.replaceAll(RegExp(r'(?!ÿ)ÿ'), '');

    newData = newData.replaceAllMapped(
        RegExp(r'\$(?![\r\n])|(?<!ÿÿÿÿÿÿÿÿÿÿÿÿ)[^\x00-\x7F]'), (match) {
      if (match.group(0) == '\$') {
        return '\n\$';
      } else {
        return '';
      }
    });

    return newData;
  }

  String message = '';
  bool uploading = false;

  void plaesewaitmassageprocess(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: "Please Wait",
      text: "Your process is currently running on the server.",
    );
  }

  void uploadFileData(BuildContext context) async {
    try {
      plaesewaitmassageprocess(context);

      File csvFile = devicedataFile;
      await uploadDeviceFile(
        context: context,
        makeId: widget.device.id.toString(),
        batteryStatus: batteryupdate,
        csvFile: csvFile,
      );
    } catch (e) {
      setState(() {
        print("Error $e");
        message = 'Error: $e';
        Navigator.of(context).pop();
        uploading = false;
      });
    } finally {}
  }

  void uploadSOHFile(BuildContext context) async {
    try {
      File textfile = SohdataFile;
      await uploadDeviceSOHFile(
        context: context,
        textfile: textfile,
      );
    } catch (e) {
      setState(() {
        print("Error $e");
        message = 'Error: $e';
        uploading = false;
      });
    } finally {}
  }

  Future<void> uploadDeviceFile({
    required BuildContext context,
    required String makeId,
    required String batteryStatus,
    required File csvFile,
  }) async {
    int bytes = csvFile.lengthSync();
    double kilobytes = bytes / 1024;
    double megabytes = kilobytes / 1024;
    String fileSize;
    if (kilobytes < 1024) {
      fileSize = kilobytes.toStringAsFixed(2) + 'KB';
    } else {
      fileSize = megabytes.toStringAsFixed(2) + 'MB';
    }

    try {
      final String deviceApis =
          staticverible.temqr + '/device.asmx/UpdateDeviceDetails';
      var request = http.MultipartRequest('POST', Uri.parse(deviceApis));

      request.fields['macid'] = makeId;
      request.fields['filesize'] = fileSize.toString();
      request.fields['batterystatus'] = batteryStatus;

      request.files
          .add(await http.MultipartFile.fromPath('filelog', csvFile.path));

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
            if (responseMessage == "This MACID is not Registered") {
              Navigator.of(context).pop();
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: "Device Error",
                text: responseMessage,
                onConfirmBtnTap: () {
                  Navigator.of(context).pop();
                },
              );
            } else if (responseMessage == "Success") {
              showMessageDialog(context, responseMessage);
              Navigator.of(context).pop();
              QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                title: "Data Transfer",
                text: responseMessage,
                onConfirmBtnTap: () {
                  Navigator.of(context).pop();
                  eraseStoredData(widget.device);
                  deleteCsvFile(csvFile.path);
                },
              );
            } else {
              Navigator.of(context).pop();
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                text: responseMessage,
                onConfirmBtnTap: () {
                  Navigator.of(context).pop();
                  deleteCsvFile(csvFile.path);
                },
              );
            }
          }
        } else {
          throw FormatException('Unexpected format for response');
        }
      } else {
        Navigator.pop(context);
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw http.ClientException(
            'Failed to load UploaddataFile HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error: $e');
      logError('$e');
      String errorMessage = 'An error occurred. Please try again.';
      if (e is SocketException) {
        errorMessage =
            'Connection failed. Please check your internet connection.';
      }
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Internet connection",
        text: errorMessage,
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        },
      );
      print('Error: $e');
      logError('$e');
    }
  }

  Future<void> deleteCsvFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
      } else {
        print('File not found: $filePath');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  void CompletedprocessMASSAGE(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Completed Process",
        text: "Thank you! All processes have been successfully completed",
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
        });
  }

  Future<void> uploadDeviceSOHFile({
    required BuildContext context,
    required File textfile,
  }) async {
    try {
      final String devicesohApis = staticverible.temqr + '/soh.asmx/AddSOHFile';

      var request = http.MultipartRequest('POST', Uri.parse(devicesohApis));

      request.files
          .add(await http.MultipartFile.fromPath('sohfile', textfile.path));
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
            if (responseMessage == "Success") {
              showMessageDialog(context, responseMessage);
              deleteCsvFile(textfile.path);
            } else {
              showMessageDialog(context, responseMessage);
              Navigator.of(context).pop();
            }
          }
        } else {
          throw FormatException('Unexpected format for response');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw http.ClientException(
            'Failed to load UploaddataFile  HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      logError('$e');
    }
  }

  Future<void> derecteraseStoredData(BluetoothDevice device) async {
    plaesewaitmassage(context);

    try {
      bool isConnected =
          await device.state.first == BluetoothDeviceState.connected;
      if (!isConnected) {
        await device.connect();
      }
      List<BluetoothService> services = await device.discoverServices();
      BluetoothService desiredService = services.firstWhere(
        (service) => service.uuid == widget.characteristic.serviceUuid,
        orElse: () => throw Exception('Service not found'),
      );
      BluetoothCharacteristic desiredCharacteristic =
          desiredService.characteristics.firstWhere(
        (characteristic) => characteristic.uuid == widget.characteristic.uuid,
        orElse: () => throw Exception('Characteristic not found'),
      );

      await desiredCharacteristic.write([0x01]);

      // Wait for 10 seconds
      await Future.delayed(Duration(seconds: 5));
      print('Stored data erased successfully.');
      derecteraseStoredDatatime(widget.service, widget.device);
    } catch (e) {
      print('Error erasing stored data: $e');
    } finally {}
  }

  String hexval1 = '07080000';
  Future<void> derecteraseStoredDatatime(
      BluetoothService customService, BluetoothDevice device) async {
    try {
      BluetoothCharacteristic desiredCharacteristic =
          customService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid.toString().toUpperCase() ==
            'F3641404-00B0-4240-BA50-05CA45BF8ABC',
        orElse: () => throw Exception('Characteristic with UUID not found'),
      );
      List<int> data = hexStringToBytes(hexval1);
      await desiredCharacteristic.write(data);

      Navigator.pop(context);
      print("Reconnected to the device");
      showMessageDialog(context, "All process done");
    } catch (e) {
      print('Error: $e');
    }
  }

  bool isvalidate = false;
  void _showPasswordDialog(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();

    void _verifyPassword(String password) {
      if (password == 'Nehhdc@2024') {
        isvalidate = true;
        Navigator.of(context).pop();
        derecteraseStoredData(widget.device);
      } else {
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Incorrect password, please try again.',
            style: TextStyle(color: Colors.white),
          ),
        ));
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Password',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                hintText: "Password", hintStyle: TextStyle(fontSize: 12)),
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                _verifyPassword(_passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }
}

class MyTime {
  int hour;
  int minute;
  int second;

  MyTime({this.hour = 0, this.minute = 0, this.second = 0});
}
