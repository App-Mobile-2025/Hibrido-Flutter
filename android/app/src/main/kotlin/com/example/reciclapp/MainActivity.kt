package com.example.reciclapp

import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.reciclapp/detector"
    private var detector: Detector? = null
    private val isDetectorInitialized = AtomicBoolean(false)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        android.util.Log.d("MainActivity", "🚀 configureFlutterEngine llamado")

        // Inicializar detector INMEDIATAMENTE
        initializeDetector()
        //aca uso Platform Channels
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                android.util.Log.d("MainActivity", "📞 Method call recibido: ${call.method}")

                when (call.method) {
                    "detectFromPath" -> {
                        val imagePath = call.argument<String>("path")
                        if (imagePath != null) {
                            detectFromPathAsync(imagePath, result)
                        } else {
                            result.error("INVALID_ARGS", "Image path is null", null)
                        }
                    }
                    "isReady" -> {
                        val ready = isDetectorInitialized.get()
                        android.util.Log.d("MainActivity", "🔍 isReady() = $ready")
                        result.success(ready)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun initializeDetector() {
        android.util.Log.d("MainActivity", "🔄 initializeDetector() INICIO")

        if (isDetectorInitialized.get()) {
            android.util.Log.d("MainActivity", "⚠️ Detector ya inicializado")
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                android.util.Log.d("MainActivity", "🔧 Creando detector...")

                val newDetector = Detector(
                    this@MainActivity,
                    "model.tflite",
                    "labels.txt"
                )

                android.util.Log.d("MainActivity", "🔧 Llamando a setup()...")
                newDetector.setup()

                detector = newDetector
                isDetectorInitialized.set(true)

                android.util.Log.d("MainActivity", "✅ Detector inicializado y listo!")
            } catch (e: Exception) {
                android.util.Log.e("MainActivity", "❌ Error inicializando detector: ${e.message}")
                e.printStackTrace()
            }
        }
    }

    private fun detectFromPathAsync(imagePath: String, result: MethodChannel.Result) {
        android.util.Log.d("MainActivity", "🔍 detectFromPathAsync() INICIO")

        CoroutineScope(Dispatchers.Main).launch {
            try {
                // Esperar a que el detector esté listo
                if (!waitForDetectorReady()) {
                    android.util.Log.e("MainActivity", "❌ Detector no está listo después de esperar")
                    result.error("NOT_READY", "Detector no se inicializó correctamente", null)
                    return@launch
                }

                android.util.Log.d("MainActivity", "✅ Detector listo, ejecutando detección")

                val detectionResult = withContext(Dispatchers.IO) {
                    performDetection(imagePath)
                }

                android.util.Log.d("MainActivity", "✅ Detección completada, enviando resultado")
                result.success(detectionResult)
            } catch (e: Exception) {
                android.util.Log.e("MainActivity", "❌ Error en detección: ${e.message}")
                e.printStackTrace()
                result.error("DETECTION_ERROR", e.message, null)
            }
        }
    }

    private suspend fun waitForDetectorReady(): Boolean = withContext(Dispatchers.IO) {
        val maxWaitMs = 15000L
        val startTime = System.currentTimeMillis()

        while (!isDetectorInitialized.get()) {
            val elapsed = System.currentTimeMillis() - startTime
            if (elapsed >= maxWaitMs) {
                android.util.Log.e("MainActivity", "❌ Timeout esperando detector (${elapsed}ms)")
                return@withContext false
            }

            if (elapsed % 1000 == 0L) { // Log cada segundo
                android.util.Log.d("MainActivity", "⏳ Esperando detector... (${elapsed}ms)")
            }

            Thread.sleep(100)
        }

        android.util.Log.d("MainActivity", "✅ Detector listo para usar")
        return@withContext true
    }

    private fun performDetection(imagePath: String): Map<String, Any> {
        android.util.Log.d("MainActivity", "🔍 performDetection() INICIO: $imagePath")

        // Verificar que el archivo existe
        val file = File(imagePath)
        if (!file.exists()) {
            android.util.Log.e("MainActivity", "❌ Archivo no encontrado: $imagePath")
            throw Exception("Archivo no encontrado: $imagePath")
        }

        // Cargar imagen
        val bitmap = BitmapFactory.decodeFile(imagePath)
        if (bitmap == null) {
            android.util.Log.e("MainActivity", "❌ No se pudo decodificar la imagen")
            throw Exception("No se pudo decodificar la imagen")
        }

        android.util.Log.d("MainActivity", "📸 Imagen cargada: ${bitmap.width}x${bitmap.height}")

        // Ejecutar detección síncrona
        val currentDetector = detector
        if (currentDetector == null) {
            android.util.Log.e("MainActivity", "❌ Detector es null")
            throw Exception("Detector es null")
        }

        android.util.Log.d("MainActivity", "🔍 Ejecutando detectSync()...")
        val detectionResult = currentDetector.detectSync(bitmap)

        android.util.Log.d("MainActivity", "✅ Detección completada: ${detectionResult.boundingBoxes.size} objetos en ${detectionResult.inferenceTime}ms")

        // Convertir resultado a mapa para Flutter
        val detections = detectionResult.boundingBoxes.map { box ->
            mapOf(
                "x1" to box.x1,
                "y1" to box.y1,
                "x2" to box.x2,
                "y2" to box.y2,
                "confidence" to box.cnf,
                "classIndex" to box.cls,
                "className" to box.clsName,
                "cx" to box.cx,
                "cy" to box.cy,
                "w" to box.w,
                "h" to box.h
            )
        }

        return mapOf(
            "detections" to detections,
            "inferenceTime" to detectionResult.inferenceTime
        )
    }
}