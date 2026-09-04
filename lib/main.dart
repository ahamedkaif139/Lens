import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/services.dart';
List<CameraDescription> cameras = [];
void main() async { WidgetsFlutterBinding.ensureInitialized(); cameras = await availableCameras(); runApp(MaterialApp(home: LensScreen(), theme: ThemeData.dark(), debugShowCheckedModeBanner: false)); }
class LensScreen extends StatefulWidget { @override State<LensScreen> createState() => _LensScreenState(); }
class _LensScreenState extends State<LensScreen> {
late CameraController controller; final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); final objectDetector = ObjectDetector(options: ObjectDetectorOptions(mode: DetectionMode.single, classifyObjects: true, multipleObjects: true));
String foundText = "Tap SCAN to copy text"; bool isScanning = false;
@override void initState() { super.initState(); controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false); controller.initialize().then((_) => setState((){})); }
Future<void> scan() async { if(isScanning) return; setState(() => isScanning = true); try { final pic = await controller.takePicture(); final inputImage = InputImage.fromFilePath(pic.path); final textResult = await textRecognizer.processImage(inputImage); setState(() { foundText = textResult.text.isEmpty? "No text" : textResult.text; isScanning = false; }); } catch(e) { setState(() { foundText = "Error: $e"; isScanning = false; }); } }
@override Widget build(BuildContext context) { if(!controller.value.isInitialized) return Scaffold(body: Center(child: CircularProgressIndicator())); return Scaffold(body: Stack(children: [CameraPreview(controller), Align(alignment: Alignment.bottomCenter, child: Container(color: Colors.black.withOpacity(0.85), padding: EdgeInsets.all(12), height: 240, width: double.infinity, child: Column(children: [Expanded(child: SingleChildScrollView(child: SelectableText(foundText, style: TextStyle(color: Colors.white)))), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ElevatedButton.icon(onPressed: () { Clipboard.setData(ClipboardData(text: foundText)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied!"))); }, icon: Icon(Icons.copy), label: Text("COPY")), ElevatedButton.icon(onPressed: isScanning? null : scan, icon: Icon(Icons.camera), label: Text(isScanning? "..." : "SCAN"))]))]))])); }
}