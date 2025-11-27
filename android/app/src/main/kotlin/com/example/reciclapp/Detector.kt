package com.example.reciclapp

import android.content.Context
import android.graphics.Bitmap
import android.os.SystemClock
import org.tensorflow.lite.DataType
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.support.common.FileUtil
import org.tensorflow.lite.support.common.ops.CastOp
import org.tensorflow.lite.support.common.ops.NormalizeOp
import org.tensorflow.lite.support.image.ImageProcessor
import org.tensorflow.lite.support.image.TensorImage
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader

class Detector(
    private val context: Context,
    private val modelPath: String,
    private val labelPath: String
) {

    private var interpreter: Interpreter? = null
    private var labels = mutableListOf<String>()

    private var tensorWidth = 0
    private var tensorHeight = 0
    private var numChannel = 0
    private var numElements = 0

    private val imageProcessor = ImageProcessor.Builder()
        .add(NormalizeOp(INPUT_MEAN, INPUT_STANDARD_DEVIATION))
        .add(CastOp(INPUT_IMAGE_TYPE))
        .build()

    fun setup() {
        try {
            android.util.Log.d("Detector", "🔧 Cargando modelo...")

            // Verificar que los assets existen
            try {
                val assetList = context.assets.list("")
                android.util.Log.d("Detector", "📁 Assets disponibles: ${assetList?.joinToString(", ")}")
            } catch (e: Exception) {
                android.util.Log.e("Detector", "❌ Error listando assets: ${e.message}")
            }

            val model = FileUtil.loadMappedFile(context, modelPath)
            val options = Interpreter.Options()
            options.numThreads = 4
            interpreter = Interpreter(model, options)

            val inputShape = interpreter?.getInputTensor(0)?.shape()
            val outputShape = interpreter?.getOutputTensor(0)?.shape()

            if (inputShape == null || outputShape == null) {
                throw Exception("No se pudieron obtener las dimensiones del modelo")
            }

            tensorWidth = inputShape[1]
            tensorHeight = inputShape[2]
            numChannel = outputShape[1]
            numElements = outputShape[2]

            android.util.Log.d("Detector", "📐 Dimensiones - Input: ${tensorWidth}x${tensorHeight}, Output: ${numChannel}x${numElements}")

            // Cargar etiquetas
            val inputStream: InputStream = context.assets.open(labelPath)
            val reader = BufferedReader(InputStreamReader(inputStream))

            var line: String? = reader.readLine()
            while (line != null && line != "") {
                labels.add(line)
                line = reader.readLine()
            }

            reader.close()
            inputStream.close()

            android.util.Log.d("Detector", "🏷️ Cargadas ${labels.size} etiquetas")
            android.util.Log.d("Detector", "✅ Setup completado exitosamente")
        } catch (e: IOException) {
            android.util.Log.e("Detector", "❌ Error en setup: ${e.message}")
            e.printStackTrace()
            throw e
        }
    }

    fun clear() {
        interpreter?.close()
        interpreter = null
    }

    // Nueva función síncrona que devuelve el resultado directamente
    fun detectSync(frame: Bitmap): DetectionResult {
        val currentInterpreter = interpreter
        if (currentInterpreter == null) {
            android.util.Log.e("Detector", "❌ Interpreter es null")
            return DetectionResult(emptyList(), 0)
        }

        if (tensorWidth == 0 || tensorHeight == 0 || numChannel == 0 || numElements == 0) {
            android.util.Log.e("Detector", "❌ Dimensiones no inicializadas")
            return DetectionResult(emptyList(), 0)
        }

        try {
            var inferenceTime = SystemClock.uptimeMillis()

            // Redimensionar imagen
            val resizedBitmap = Bitmap.createScaledBitmap(frame, tensorWidth, tensorHeight, false)

            // Preparar tensor de entrada
            val tensorImage = TensorImage(DataType.FLOAT32)
            tensorImage.load(resizedBitmap)
            val processedImage = imageProcessor.process(tensorImage)
            val imageBuffer = processedImage.buffer

            // Preparar tensor de salida
            val output = TensorBuffer.createFixedSize(
                intArrayOf(1, numChannel, numElements),
                OUTPUT_IMAGE_TYPE
            )

            // Ejecutar inferencia
            currentInterpreter.run(imageBuffer, output.buffer)

            // Procesar resultados
            val bestBoxes = bestBox(output.floatArray)
            inferenceTime = SystemClock.uptimeMillis() - inferenceTime

            android.util.Log.d("Detector", "⏱️ Inferencia completada en ${inferenceTime}ms")

            if (bestBoxes == null || bestBoxes.isEmpty()) {
                android.util.Log.d("Detector", "📭 No se detectaron objetos")
                return DetectionResult(emptyList(), inferenceTime)
            } else {
                android.util.Log.d("Detector", "✅ Detectados ${bestBoxes.size} objetos")
                return DetectionResult(bestBoxes, inferenceTime)
            }
        } catch (e: Exception) {
            android.util.Log.e("Detector", "❌ Error durante detección: ${e.message}")
            e.printStackTrace()
            return DetectionResult(emptyList(), 0)
        }
    }

    private fun bestBox(array: FloatArray): List<BoundingBox>? {
        val boundingBoxes = mutableListOf<BoundingBox>()

        for (c in 0 until numElements) {
            var maxConf = -1.0f
            var maxIdx = -1
            var j = 4
            var arrayIdx = c + numElements * j

            while (j < numChannel) {
                if (array[arrayIdx] > maxConf) {
                    maxConf = array[arrayIdx]
                    maxIdx = j - 4
                }
                j++
                arrayIdx += numElements
            }

            if (maxConf > CONFIDENCE_THRESHOLD) {
                val clsName = if (maxIdx < labels.size) labels[maxIdx] else "unknown"
                val cx = array[c]
                val cy = array[c + numElements]
                val w = array[c + numElements * 2]
                val h = array[c + numElements * 3]
                val x1 = cx - (w / 2F)
                val y1 = cy - (h / 2F)
                val x2 = cx + (w / 2F)
                val y2 = cy + (h / 2F)

                // Validar coordenadas
                if (x1 < 0F || x1 > 1F) continue
                if (y1 < 0F || y1 > 1F) continue
                if (x2 < 0F || x2 > 1F) continue
                if (y2 < 0F || y2 > 1F) continue

                boundingBoxes.add(
                    BoundingBox(
                        x1 = x1, y1 = y1, x2 = x2, y2 = y2,
                        cx = cx, cy = cy, w = w, h = h,
                        cnf = maxConf, cls = maxIdx, clsName = clsName
                    )
                )
            }
        }

        if (boundingBoxes.isEmpty()) {
            android.util.Log.d("Detector", "📊 No hay detecciones sobre el umbral de confianza")
            return null
        }

        android.util.Log.d("Detector", "📊 ${boundingBoxes.size} cajas antes de NMS")
        val filtered = applyNMS(boundingBoxes)
        android.util.Log.d("Detector", "📊 ${filtered.size} cajas después de NMS")

        return filtered
    }

    private fun applyNMS(boxes: List<BoundingBox>): MutableList<BoundingBox> {
        val sortedBoxes = boxes.sortedByDescending { it.cnf }.toMutableList()
        val selectedBoxes = mutableListOf<BoundingBox>()

        while (sortedBoxes.isNotEmpty()) {
            val first = sortedBoxes.first()
            selectedBoxes.add(first)
            sortedBoxes.remove(first)

            val iterator = sortedBoxes.iterator()
            while (iterator.hasNext()) {
                val nextBox = iterator.next()
                val iou = calculateIoU(first, nextBox)
                if (iou >= IOU_THRESHOLD) {
                    iterator.remove()
                }
            }
        }

        return selectedBoxes
    }

    private fun calculateIoU(box1: BoundingBox, box2: BoundingBox): Float {
        val x1 = maxOf(box1.x1, box2.x1)
        val y1 = maxOf(box1.y1, box2.y1)
        val x2 = minOf(box1.x2, box2.x2)
        val y2 = minOf(box1.y2, box2.y2)
        val intersectionArea = maxOf(0F, x2 - x1) * maxOf(0F, y2 - y1)
        val box1Area = box1.w * box1.h
        val box2Area = box2.w * box2.h
        return intersectionArea / (box1Area + box2Area - intersectionArea)
    }

    // Clase de datos para el resultado
    data class DetectionResult(
        val boundingBoxes: List<BoundingBox>,
        val inferenceTime: Long
    )

    companion object {
        private const val INPUT_MEAN = 0f
        private const val INPUT_STANDARD_DEVIATION = 255f
        private val INPUT_IMAGE_TYPE = DataType.FLOAT32
        private val OUTPUT_IMAGE_TYPE = DataType.FLOAT32
        private const val CONFIDENCE_THRESHOLD = 0.3F
        private const val IOU_THRESHOLD = 0.5F
    }
}