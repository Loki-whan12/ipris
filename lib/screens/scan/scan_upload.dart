import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import '../../services/backen_services.dart';
import '../../values/app_colors.dart';
import 'results.dart';

class ScanPage extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;

  const ScanPage({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.box,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isLoading = false;
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraViewVisible = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(_cameras[0], ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.jpeg);

      await _cameraController.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showErrorSnackbar(context, "Error initializing camera: ${e.toString()}");
    }
  }

  //to capture an image with camera
  Future<void> _takePicture(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final XFile image = await _cameraController.takePicture();
      if (!mounted) return;

      await handleImageFromCamera(File(image.path).readAsBytesSync(), context);
    } catch (e) {
      _showErrorSnackbar(context, "Error capturing image: ${e.toString()}");
      setState(() {
        isLoading = false;
        _isCameraViewVisible = false;
      });
    }
  }

  Future<void> _captureImageWithCamera(BuildContext context) async {
    try {
      if (!_isCameraInitialized) {
        await _initializeCamera();
      }

      setState(() {
        _isCameraViewVisible = true;
      });
    } catch (e) {
      _showErrorSnackbar(context, "Error initializing camera: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleImageFromGallery(
      Uint8List bytes, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final checkResponse = await MyBackendService().checkIfPlant(bytes);
      print('CheckIfPlant response: $checkResponse');

      await _processPlantResponse(checkResponse, bytes, context);
    } on PlatformException catch (e) {
      _showErrorDialog(context, 'Failed to pick image: ${e.message}');
    } catch (e) {
      _showErrorDialog(context, 'Error occurred: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //handling the image from camera
  Future<void> handleImageFromCamera(
      Uint8List bytes, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // final checkResponse = await MyBackendService().checkIfPlant(bytes);
      // print('CheckIfPlant response: $checkResponse');

      // await _processPlantResponse(checkResponse, bytes, context);

      //route to check to see if Image contains plant
      final checkIfPlantResponse = await MyBackendService().checkIfPlant(bytes);

      //first check the response from MyBackendService().checkIfPlant(bytes);
      if (checkIfPlantResponse != null && checkIfPlantResponse is Map) {
        if (checkIfPlantResponse.containsKey("result")) {
          if (!(checkIfPlantResponse['result'] == "Not a plant")) {
            _showErrorDialog(context, "The image contains a plant");
          } else {
            //the image is not a plant
            setState(() {
              isLoading = false;
            });
            _showErrorDialog(context,
                "The image does not contain a plant. Please try again with a different image.");
          }
        } else if (checkIfPlantResponse.containsKey("error")) {
          setState(() {
            isLoading = false;
          });
          //check if the error is the key.
          _showErrorDialog(context, checkIfPlantResponse['error'].toString());
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // network error and not able to check if plant or not...
        _showErrorDialog(context, 'Sorry, your network connection is unstable');
      }
      //end for checking is plant ...

//end for camera  code.....
    } on PlatformException catch (e) {
      _showErrorDialog(context, 'Failed to pick image: ${e.message}');
    } catch (e) {
      _showErrorDialog(context, 'Error occurred: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
        _isCameraViewVisible = false;
      });
    }
  }

  Future<void> handleImageFromCameraaa(
      Uint8List bytes, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await MyBackendService()
          .identifyPlantAndGetUses(bytes, "filename.jpg");

      if (response != null && response is Map) {
        if (response.containsKey('message') &&
            response['message'] == 'success') {
          if (response['plant_info'] != null &&
              response['plant_info']['result'] != null &&
              response['plant_info']['result']['is_plant'] != null &&
              response['plant_info']['result']['is_plant']['binary'] != null &&
              response['plant_info']['result']['is_plant']['binary'] == false) {
            _showErrorDialog(context,
                "The image does not contain a plant. Please try again with a different image.");
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(
                  imageBytes: bytes,
                  box: widget.box,
                  currentTheme: widget.currentTheme,
                  onThemeChanged: widget.onThemeChanged,
                  showButtonsOfScanScreen: true,
                  plantInfo: response['plant_info'] ?? {},
                  plantUses: response['plant_uses']?['plant_uses'] ?? {},
                ),
              ),
            );
          }
        } else if (response.containsKey('error')) {
          _showErrorDialog(context, response['error']);
        } else {
          // Handle unexpected response format
          _showErrorDialog(context, "Unexpected response format");
        }
      } else {
        // Handle null or unexpected response
        _showErrorDialog(context, "Unexpected or null response");
      }
    } on PlatformException catch (e) {
      _showErrorDialog(context, 'Failed to pick image');
    } catch (e) {
      _showErrorDialog(context, 'Error occurred');
    } finally {
      setState(() {
        isLoading = false;
        _isCameraViewVisible = false;
      });
    }
  }

  Future<void> _processPlantResponse(
    Map<String, dynamic> checkResponse,
    Uint8List bytes,
    BuildContext context,
  ) async {
    if (checkResponse.containsKey('result')) {
      if (checkResponse['result'] == 0) {
        // Image contains a plant, now identify the plant and get uses
        final identifyResponse = await MyBackendService()
            .identifyPlantAndGetUses(bytes, "filename.jpg");

        if (identifyResponse is Map &&
            identifyResponse.containsKey('message') &&
            identifyResponse['message'] == 'success') {
          if (identifyResponse['plant_info']['result']['is_plant']['binary'] ==
              false) {
            _showErrorDialog(
              context,
              "The image does not contain a plant. Please try again with a different image.",
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(
                  imageBytes: bytes,
                  box: widget.box,
                  currentTheme: widget.currentTheme,
                  onThemeChanged: widget.onThemeChanged,
                  showButtonsOfScanScreen: true,
                  plantInfo: identifyResponse['plant_info'] ?? {},
                  plantUses:
                      identifyResponse['plant_uses']?['plant_uses'] ?? {},
                ),
              ),
            );
          }
        } else if (identifyResponse.containsKey('error')) {
          _showErrorDialog(context, identifyResponse['error']);
        } else {
          _showErrorDialog(context, "Unexpected response format");
        }
      } else if (checkResponse['result'] == 1) {
        _showErrorDialog(
          context,
          "The image does not contain a plant. Please upload an image with a plant.",
        );
      } else {
        _showErrorDialog(context, "Unexpected result from the backend.");
      }
    } else if (checkResponse.containsKey('error')) {
      _showErrorDialog(context, checkResponse['error']);
    } else {
      _showErrorDialog(context, "Unsupported image format detected");
    }
  }

  Future<void> handleImage(Uint8List bytes, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      //route to check to see if Image contains plant
      final checkIfPlantResponse = await MyBackendService().checkIfPlant(bytes);

      //first check the response from MyBackendService().checkIfPlant(bytes);
      if (checkIfPlantResponse != null && checkIfPlantResponse is Map) {
        if (checkIfPlantResponse.containsKey("result")) {
          if (!(checkIfPlantResponse['result'] == "Not a plant")) {
            setState(() {
              isLoading = false;
            });
            _showErrorDialog(context, "The image contains a plant");
          } else {
            //the image is not a plant
            setState(() {
              isLoading = false;
            });
            _showErrorDialog(context,
                "The image does not contain a plant. Please try again with a different image.");
          }
        } else if (checkIfPlantResponse.containsKey("error")) {
          setState(() {
            isLoading = false;
          });
          //check if the error is the key.
          _showErrorDialog(context, checkIfPlantResponse['error'].toString());
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // network error and not able to check if plant or not...
        _showErrorDialog(context, 'Sorry, your network connection is unstable');
      }
      //end for checking is plant ...
    } on PlatformException catch (e) {
      _showErrorDialog(context, 'Failed to pick image: ${e.message}');
    } catch (e) {
      _showErrorDialog(context, 'Error occurred: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    // try {
    //   final checkResponse = await MyBackendService().checkIfPlant(bytes);
    //   print('CheckIfPlant response: $checkResponse');

    //   // await _processPlantResponse(checkResponse, bytes, context);
    // } on PlatformException catch (e) {
    //   _showErrorDialog(context, 'Failed to pick image: ${e.message}');
    // } catch (e) {
    //   _showErrorDialog(context, 'Error occurred: ${e.toString()}');
    // } finally {
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
  }

  Future<void> pickDefaultImage(BuildContext context) async {
    const imagePath = 'assets/imgs/eor.jpg';
    final bytes = await rootBundle.load(imagePath);
    handleImage(bytes.buffer.asUint8List(), context);
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildElevatedButton(BuildContext context,
      {required VoidCallback onPressed,
      required IconData icon,
      required String text}) {
    return SizedBox(
      width: 170,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Future<void> pickImageGallery(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);

      final bytes = await imageTemporary.readAsBytes();

      // final response = await MyBackendService()
      //     .identifyPlantAndGetUses(bytes, "filename.jpg")
      //     .whenComplete(() {
      //   setState(() {
      //     isLoading = false;
      //   });
      // });

      //route to check to see if Image contains plant
      final checkIfPlantResponse = await MyBackendService().checkIfPlant(bytes);

      //first check the response from MyBackendService().checkIfPlant(bytes);
      if (checkIfPlantResponse != null && checkIfPlantResponse is Map) {
        if (checkIfPlantResponse.containsKey("result")) {
          if (!(checkIfPlantResponse['result'] == "Not a plant")) {
            // if (response != null && response is Map) {
            //   if (response.containsKey('message') &&
            //       response['message'] == 'success') {
            //     if (response['plant_info'] != null &&
            //         response['plant_info']['result'] != null &&
            //         response['plant_info']['result']['is_plant'] != null &&
            //         response['plant_info']['result']['is_plant']['binary'] !=
            //             null &&
            //         response['plant_info']['result']['is_plant']['binary'] ==
            //             false) {
            //       _showErrorDialog(context,
            //           "The image does not contain a plant. Please try again with a different image.");
            //     } else {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => ResultsScreen(
            //             imageBytes: bytes,
            //             box: widget.box,
            //             currentTheme: widget.currentTheme,
            //             onThemeChanged: widget.onThemeChanged,
            //             showButtonsOfScanScreen: true,
            //             plantInfo: response['plant_info'] ?? {},
            //             plantUses: response['plant_uses']?['plant_uses'] ?? {},
            //           ),
            //         ),
            //       );
            //     }
            //   } else if (response.containsKey('error')) {
            //     setState(() {
            //       isLoading = false;
            //     });
            //     _showErrorDialog(context, response['error']);
            //   } else {
            //     setState(() {
            //       isLoading = false;
            //     });
            //     // Handle unexpected response format
            //     _showErrorDialog(context, "Unexpected response format");
            //   }
            // } else {
            //   // Handle null or unexpected response
            //   _showErrorDialog(context, "Unexpected or null response");
            // }
            // setState(() {
            //   isLoading = false;
            // });
            // //end of plant.id checking
          } else {
            //the image is not a plant
            setState(() {
              isLoading = false;
            });
            _showErrorDialog(context,
                "The image does not contain a plant. Please try again with a different image.");
          }
        } else if (checkIfPlantResponse.containsKey("error")) {
          setState(() {
            isLoading = false;
          });
          //check if the error is the key.
          _showErrorDialog(context, checkIfPlantResponse['error'].toString());
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // network error and not able to check if plant or not...
        _showErrorDialog(context, 'Sorry, your network connection is unstable');
      }
      //end for checking is plant ...
    } on PlatformException catch (e) {
      _showErrorDialog(context, 'Failed to pick image');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(context, 'Error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScanPageScreen(context);
  }

  Scaffold buildScanPageScreen(BuildContext context) {
    return Scaffold(
      appBar: _isCameraViewVisible
          ? null
          : AppBar(
              toolbarHeight: 120,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.defaultGradient,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Capture or Upload!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: _isCameraViewVisible
                        ? CameraPreview(_cameraController)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              _buildElevatedButton(
                                context,
                                onPressed: () => pickImageGallery(context),
                                icon: Icons.photo_size_select_actual_rounded,
                                text: "Pick Gallery",
                              ),
                              const SizedBox(height: 10),
                              const SizedBox(height: 10),
                              _buildElevatedButton(
                                context,
                                onPressed: () => pickDefaultImage(context),
                                icon: Icons.photo_size_select_actual_rounded,
                                text: "Default",
                              ),
                              const SizedBox(height: 10),
                              _buildElevatedButton(
                                context,
                                onPressed: () =>
                                    _captureImageWithCamera(context),
                                icon: Icons.camera,
                                text: "Pick Camera",
                              ),
                            ],
                          ),
                  ),
                  if (_isCameraViewVisible)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isCameraViewVisible = false;
                              });
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text("Cancel"),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _takePicture(context),
                            icon: const Icon(Icons.camera),
                            label: const Text("Capture"),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
