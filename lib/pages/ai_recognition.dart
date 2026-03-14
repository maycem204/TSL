import 'package:flutter/material.dart';
import '../widgets/navigation_wrapper.dart';

const Color primaryRed = Color(0xFFE60012);
const Color bgGrey = Color(0xFFF5F5F5);

// PAGE DE RECONNAISSANCE IA PAR CAMÉRA
class AIRecognitionPage extends StatefulWidget {
  const AIRecognitionPage({super.key});

  @override
  State<AIRecognitionPage> createState() => _AIRecognitionPageState();
}

class _AIRecognitionPageState extends State<AIRecognitionPage> {
  bool isLoading = false;
  String? detectedSign;
  String? detectedWord;
  double? confidence;

  // FONCTION POUR ENVOYER L'IMAGE AU MODÈLE IA
  Future<void> _recognizeSignFromCamera() async {
    setState(() => isLoading = true);

    try {
      // TODO: INTÉGRER VOTRE MODÈLE IA ICI
      // EXEMPLE D'APPEL API:
      /*
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;

      // Conversion de l'image en bytes
      final imageBytes = await image.readAsBytes();

      // Envoi au serveur/API du modèle IA
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://votre-api-ia.com/detect'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'sign.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      setState(() {
        detectedSign = jsonResponse['sign'];
        detectedWord = jsonResponse['word'];
        confidence = jsonResponse['confidence'];
      });
      */

      // SIMULATION POUR TESTER (À REMPLACER PAR VOTRE VRAI MODÈLE)
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        detectedSign = "Bonjour";
        detectedWord = "hello";
        confidence = 0.92;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetRecognition() {
    setState(() {
      detectedSign = null;
      detectedWord = null;
      confidence = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a2332),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // ZONE DE CAMÉRA - MODE DÉMO
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xFF2a3a52),
                  ),
                  child: Stack(
                    children: [
                      // AFFICHAGE DE LA CAMÉRA OU PLACEHOLDER
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (detectedSign == null && !isLoading)
                              Column(
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Mode Démo",
                                    style: TextStyle(
                                      fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          if (isLoading)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryRed,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Analyse en cours...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          if (detectedSign != null && !isLoading)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: primaryRed,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        "Signe détecté!",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // TEXTE D'INFO
                    if (detectedSign == null && !isLoading)
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            "Caméra non disponible. Utilisez le bouton\nci-dessous pour tester la reconnaissance.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // RÉSULTATS DE LA RECONNAISSANCE
              if (detectedSign != null && !isLoading)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Résultats",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // SIGNE DÉTECTÉ
                      _buildResultRow(
                        label: "Signe:",
                        value: detectedSign!,
                        color: primaryRed,
                      ),
                      const SizedBox(height: 15),

                      // MOT EN FRANÇAIS
                      _buildResultRow(
                        label: "Mot:",
                        value: detectedWord ?? "N/A",
                        color: Colors.white,
                      ),
                      const SizedBox(height: 15),

                      // CONFIANCE
                      _buildConfidenceBar(confidence ?? 0.0),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              // MESSAGE D'INFO
              Text(
                "Caméra non disponible. Utilisez le bouton\nci-dessous pour tester la reconnaissance.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),

              // BOUTONS D'ACTION
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _recognizeSignFromCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Tap to recognize sign",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // BOUTON RÉINITIALISER
              if (detectedSign != null)
                Column(
                  children: [
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: _resetRecognition,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: primaryRed,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Nouvelle reconnaissance",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    final percentage = (confidence * 100).toStringAsFixed(0);
    final color = confidence > 0.8
        ? Colors.green
        : confidence > 0.6
            ? Colors.yellow
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Confiance:",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
