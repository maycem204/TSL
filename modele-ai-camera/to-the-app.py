from ultralytics import YOLO

model = YOLO('classifieur_signe.pt')
# ONNX évite les conflits Protobuf/TensorFlow
model.export(format='onnx')