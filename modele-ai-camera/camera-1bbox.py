import cv2
import numpy as np
from ultralytics import YOLO
import time

# --- CONFIGURATION ---
# Assure-toi que ces fichiers sont dans le même dossier que ce script
PATH_DETECTOR = 'detecteur_main.pt'
PATH_CLASSIFIER = 'classifieur_signe.pt'

# 1. Chargement des modèles
print("Wait... Chargement des modèles IA...")
detector = YOLO(PATH_DETECTOR)
classifier = YOLO(PATH_CLASSIFIER)

# 2. Initialisation de la Webcam
cap = cv2.VideoCapture(0)
prev_time = 0

print("🚀 Système prêt ! Appuyez sur 'q' pour quitter.")

while cap.isOpened():
    success, frame = cap.read()
    if not success:
        break

    # Effet miroir pour que ce soit plus naturel
    frame = cv2.flip(frame, 1)
    h_frame, w_frame, _ = frame.shape

    # 3. Détection des mains (On récupère toutes les mains)
    results_det = detector(frame, conf=0.4, verbose=False)
    boxes = results_det[0].boxes.xyxy.cpu().numpy()

    if len(boxes) > 0:
        # --- LOGIQUE D'ENGLOBEMENT (Merge Bounding Boxes) ---
        # On calcule les bords extrêmes pour englober TOUTES les mains détectées
        x1_min = np.min(boxes[:, 0])
        y1_min = np.min(boxes[:, 1])
        x2_max = np.max(boxes[:, 2])
        y2_max = np.max(boxes[:, 3])

        # --- CALCUL DU CROP CARRÉ AVEC PADDING ---
        w_box = x2_max - x1_min
        h_box = y2_max - y1_min
        
        # On prend le côté le plus long + 30% de marge pour ne pas couper les doigts
        side = int(max(w_box, h_box) * 1.3)
        
        # Centre de la zone détectée
        cx, cy = (x1_min + x2_max) // 2, (y1_min + y2_max) // 2

        # Coordonnées du carré final
        fx1 = max(0, int(cx - side // 2))
        fy1 = max(0, int(cy - side // 2))
        fx2 = min(w_frame, int(fx1 + side))
        fy2 = min(h_frame, int(fy1 + side))

        # Découpe de l'image (Le Crop)
        hand_crop = frame[fy1:fy2, fx1:fx2]

        if hand_crop.size > 0:
            # 4. Classification du signe sur le bloc entier
            results_cls = classifier(hand_crop, verbose=False)
            
            prob = results_cls[0].probs.top1conf.item()
            index = results_cls[0].probs.top1
            label = results_cls[0].names[index]

            # 5. Affichage visuel
            # Vert si confiance > 80%, sinon Orange
            color = (0, 255, 0) if prob > 0.8 else (0, 165, 255)
            
            # Dessiner le rectangle englobant
            cv2.rectangle(frame, (fx1, fy1), (fx2, fy2), color, 3)
            
            # Afficher le texte (Label + Confiance)
            header = f"{label.upper()} {prob:.1%}"
            cv2.rectangle(frame, (fx1, fy1 - 35), (fx1 + 250, fy1), color, -1) # Fond du texte
            cv2.putText(frame, header, (fx1 + 5, fy1 - 10), 
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)

    # Calcul des FPS
    curr_time = time.time()
    fps = 1 / (curr_time - prev_time)
    prev_time = curr_time
    cv2.putText(frame, f"FPS: {int(fps)}", (20, 50), 
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)

    # Affichage de la fenêtre
    cv2.imshow('Sign Language Detection - Global Mode', frame)

    # Quitter avec 'q'
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Nettoyage
cap.release()
cv2.destroyAllWindows()
print("Programme terminé proprement.")