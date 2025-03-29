"use client"

import { useState, useRef, useEffect } from "react"
import { Camera, X, RotateCcw, Check } from "lucide-react"
import Image from "next/image"

type ScanState = "welcome" | "scanning" | "processing" | "results"
type MedicationInfo = {
  name: string
  dosage: string
  frequency: string
  duration: string
}

export default function PrescriptionScanner() {
  const [scanState, setScanState] = useState<ScanState>("welcome")
  const [capturedImage, setCapturedImage] = useState<string | null>(null)
  const [medications, setMedications] = useState<MedicationInfo[]>([])
  const [selectedMedication, setSelectedMedication] = useState<MedicationInfo | null>(null)
  const [showWebview, setShowWebview] = useState(false)
  const [processingProgress, setProcessingProgress] = useState(0)
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const streamRef = useRef<MediaStream | null>(null)

  // Start camera when entering scanning state
  useEffect(() => {
    if (scanState === "scanning") {
      startCamera()
    } else {
      stopCamera()
    }

    return () => {
      stopCamera()
    }
  }, [scanState])

  // Simulate processing progress
  useEffect(() => {
    if (scanState === "processing") {
      const interval = setInterval(() => {
        setProcessingProgress((prev) => {
          const newProgress = prev + 5
          if (newProgress >= 100) {
            clearInterval(interval)
            // Simulate OCR + AI results
            const mockMedications: MedicationInfo[] = [
              {
                name: "Amoxicillin",
                dosage: "500mg",
                frequency: "3 times daily",
                duration: "7 days",
              },
              {
                name: "Ibuprofen",
                dosage: "400mg",
                frequency: "as needed",
                duration: "5 days",
              },
            ]
            setMedications(mockMedications)
            setScanState("results")
          }
          return newProgress
        })
      }, 100)

      return () => clearInterval(interval)
    }
  }, [scanState])

  const startCamera = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: "environment" },
      })

      streamRef.current = stream

      if (videoRef.current) {
        videoRef.current.srcObject = stream
      }
    } catch (err) {
      console.error("Error accessing camera:", err)
    }
  }

  const stopCamera = () => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop())
      streamRef.current = null
    }
  }

  const captureImage = () => {
    if (videoRef.current && canvasRef.current) {
      const video = videoRef.current
      const canvas = canvasRef.current
      const context = canvas.getContext("2d")

      if (context) {
        canvas.width = video.videoWidth
        canvas.height = video.videoHeight
        context.drawImage(video, 0, 0, canvas.width, canvas.height)

        const imageDataUrl = canvas.toDataURL("image/png")
        setCapturedImage(imageDataUrl)
        setScanState("processing")
        setProcessingProgress(0)
      }
    }
  }

  const resetScan = () => {
    setCapturedImage(null)
    setMedications([])
    setSelectedMedication(null)
    setShowWebview(false)
    setScanState("welcome")
  }

  const retakePicture = () => {
    setCapturedImage(null)
    setScanState("scanning")
  }

  const viewMedicationDetails = (medication: MedicationInfo) => {
    setSelectedMedication(medication)
    setShowWebview(true)
  }

  const closeWebview = () => {
    setShowWebview(false)
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-primary texture-container">
      {/* Background Textures */}
      <div className="texture-bg">
        <Image src="/group-68150.svg" alt="" fill className="object-cover" />
      </div>
      <div className="texture-bg" style={{ opacity: 0.7 }}>
        <Image src="/group-68151.svg" alt="" fill className="object-cover" />
      </div>
      <div className="texture-bg" style={{ opacity: 0.5 }}>
        <Image src="/group-68152.svg" alt="" fill className="object-cover" />
      </div>

      <div className="w-full max-w-md mx-auto h-screen flex flex-col items-center justify-center px-4 relative z-10">
        {scanState === "welcome" && (
          <div className="flex flex-col items-start w-full h-full justify-between py-16">
            <div className="space-y-4 mt-16">
              <h1 className="text-4xl font-bold text-white">Prescription Scanner</h1>
              <div className="space-y-1">
                <p className="text-white">Welcome to Prescription Scanner,</p>
                <p className="text-white">Point your camera at a prescription to identify medications</p>
              </div>
            </div>
            <button
              onClick={() => setScanState("scanning")}
              className="w-full py-4 rounded-full bg-secondary text-white font-medium"
            >
              GET STARTED
            </button>
          </div>
        )}

        {scanState === "scanning" && (
          <div className="flex flex-col items-center w-full h-full justify-between py-8">
            <div className="w-full h-3/4 bg-gray rounded-lg overflow-hidden relative">
              <video ref={videoRef} autoPlay playsInline className="w-full h-full object-cover" />
              <div className="absolute inset-0 border-2 border-green border-dashed m-8 pointer-events-none"></div>
              <p className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-green text-center">
                Line your prescription in the dashed area
              </p>
            </div>

            <div className="flex items-center justify-center mt-8 space-x-4">
              <button
                onClick={() => setScanState("welcome")}
                className="w-12 h-12 rounded-full bg-gray/80 flex items-center justify-center"
              >
                <X className="w-6 h-6 text-primary" />
              </button>

              <button
                onClick={captureImage}
                className="w-16 h-16 rounded-full bg-gray/80 flex items-center justify-center"
              >
                <Camera className="w-10 h-10 text-primary" />
              </button>
            </div>

            {/* Hidden canvas for capturing image */}
            <canvas ref={canvasRef} className="hidden" />
          </div>
        )}

        {scanState === "processing" && (
          <div className="flex flex-col items-center w-full h-full justify-center py-8 space-y-8">
            {capturedImage && (
              <div className="w-full h-1/2 bg-gray rounded-lg overflow-hidden">
                <img
                  src={capturedImage || "/placeholder.svg"}
                  alt="Captured prescription"
                  className="w-full h-full object-contain"
                />
              </div>
            )}

            <div className="w-full space-y-4">
              <div className="flex items-center justify-between">
                <p className="text-white">Processing prescription...</p>
                <p className="text-white">{processingProgress}%</p>
              </div>

              <div className="w-full bg-gray/30 rounded-full h-2">
                <div className="bg-secondary h-2 rounded-full" style={{ width: `${processingProgress}%` }}></div>
              </div>

              <div className="text-white text-sm">
                <p>• Extracting text with OCR</p>
                <p>• Identifying medications with AI</p>
                <p>• Analyzing dosage information</p>
              </div>
            </div>

            <button
              onClick={retakePicture}
              className="py-2 px-4 rounded-full bg-gray/30 text-white flex items-center space-x-2"
            >
              <RotateCcw className="w-4 h-4" />
              <span>Retake</span>
            </button>
          </div>
        )}

        {scanState === "results" && !showWebview && (
          <div className="flex flex-col items-center w-full h-full justify-between py-8">
            <div className="w-full space-y-4">
              <h2 className="text-2xl font-bold text-white">Identified Medications</h2>

              <div className="space-y-3 max-h-[60vh] overflow-y-auto">
                {medications.map((med, index) => (
                  <div
                    key={index}
                    className="bg-white/10 backdrop-blur-sm rounded-lg p-4 border border-white/20"
                    onClick={() => viewMedicationDetails(med)}
                  >
                    <div className="flex justify-between items-center">
                      <div>
                        <h3 className="text-white font-medium text-lg">{med.name}</h3>
                        <p className="text-white/80 text-sm">
                          {med.dosage} • {med.frequency}
                        </p>
                      </div>
                      <div className="bg-green/20 p-1 rounded-full">
                        <Check className="w-5 h-5 text-green" />
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4 border border-white/20">
                <p className="text-white text-sm">
                  <span className="font-medium">AI Confidence:</span> High (92%)
                </p>
                <p className="text-white text-sm">
                  <span className="font-medium">OCR Quality:</span> Good
                </p>
              </div>
            </div>

            <div className="w-full space-y-3">
              <button onClick={resetScan} className="w-full py-4 rounded-full bg-secondary text-white font-medium">
                Scan Another Prescription
              </button>
            </div>
          </div>
        )}

        {showWebview && selectedMedication && (
          <div className="flex flex-col w-full h-full">
            <div className="bg-secondary/90 p-4 flex items-center rounded-b-lg shadow-md">
              <button onClick={closeWebview} className="p-2 rounded-full hover:bg-primary/20">
                <X className="w-6 h-6 text-white" />
              </button>
              <h2 className="text-white text-lg font-medium mx-auto">{selectedMedication.name} Details</h2>
            </div>

            <div className="flex-1 bg-white rounded-t-lg mt-4 p-4 overflow-y-auto">
              <div className="space-y-4">
                <div className="border border-gray p-4 rounded-lg">
                  <div className="flex justify-between mb-2">
                    <span className="font-medium">Medication:</span>
                    <span>{selectedMedication.name}</span>
                  </div>
                  <div className="flex justify-between mb-2">
                    <span className="font-medium">Dosage:</span>
                    <span>{selectedMedication.dosage}</span>
                  </div>
                  <div className="flex justify-between mb-2">
                    <span className="font-medium">Frequency:</span>
                    <span>{selectedMedication.frequency}</span>
                  </div>
                  <div className="flex justify-between mb-2">
                    <span className="font-medium">Duration:</span>
                    <span>{selectedMedication.duration}</span>
                  </div>
                </div>

                <div className="border border-gray p-4 rounded-lg">
                  <h3 className="font-medium mb-2">Description</h3>
                  <p className="text-sm text-gray-700">
                    {selectedMedication.name === "Amoxicillin"
                      ? "Amoxicillin is a penicillin antibiotic that fights bacteria. It is used to treat many different types of infection caused by bacteria, such as tonsillitis, bronchitis, pneumonia, and infections of the ear, nose, throat, skin, or urinary tract."
                      : "Ibuprofen is a nonsteroidal anti-inflammatory drug (NSAID). It works by reducing hormones that cause inflammation and pain in the body. It is used to reduce fever and treat pain or inflammation caused by many conditions such as headache, toothache, back pain, arthritis, menstrual cramps, or minor injury."}
                  </p>
                </div>

                <div className="border border-gray p-4 rounded-lg">
                  <h3 className="font-medium mb-2">Side Effects</h3>
                  <ul className="text-sm text-gray-700 list-disc pl-5 space-y-1">
                    {selectedMedication.name === "Amoxicillin" ? (
                      <>
                        <li>Diarrhea</li>
                        <li>Stomach upset</li>
                        <li>Nausea</li>
                        <li>Vomiting</li>
                        <li>Rash</li>
                      </>
                    ) : (
                      <>
                        <li>Upset stomach</li>
                        <li>Mild heartburn</li>
                        <li>Nausea</li>
                        <li>Headache</li>
                        <li>Dizziness</li>
                      </>
                    )}
                  </ul>
                </div>

                <button className="w-full py-3 rounded-lg bg-primary text-white font-medium">Order Medication</button>
              </div>
            </div>
          </div>
        )}
      </div>
    </main>
  )
}

