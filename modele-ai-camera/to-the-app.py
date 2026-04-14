from ultralytics import YOLO

model = YOLO('classifieur_signe.pt')
model.export(format='tflite') # Génère un fichier .tflite