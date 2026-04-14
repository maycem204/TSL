import cv2
from ultralytics import YOLO
import time
import json
import sys
import os

# --- CHARGEMENT DES MODÈLES LOCAUX ---
detector = YOLO('detecteur_main.pt') 
classifier = YOLO('classifieur_signe.pt')

# Configuration
OUTPUT_FILE = "detection_results.json"
FPS_LIMIT = 30  # Limiter à 30 FPS pour la performance

print("🚀 Système prêt ! Signez devant la caméra.")
print(f"📤 Les résultats seront sauvegardés dans: {OUTPUT_FILE}")

# Lancement de la webcam locale
cap = cv2.VideoCapture(0)

# Vérifier si la caméra est bien ouverte
if not cap.isOpened():
    print("❌ Erreur: Impossible d'ouvrir la caméra")
    sys.exit(1)

# Configurer la résolution pour de meilleures performances
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

prev_time = 0
detection_count = 0
last_detections = []

try:
    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            print("❌ Erreur lecture caméra")
            break

        current_time = time.time()
        
        # Limiter les FPS pour la performance
        if current_time - prev_time < 1.0 / FPS_LIMIT:
            continue

        # 1. Détection de la main
        results_det = detector(frame, conf=0.4, verbose=False)
        
        current_detections = []
        
        for r in results_det:
            boxes = r.boxes.xyxy.cpu().numpy()
            
            for box in boxes:
                x1, y1, x2, y2 = map(int, box)
                
                # --- LOGIQUE DE CROP (Carré + Padding) ---
                w, h = x2 - x1, y2 - y1
                side = int(max(w, h) * 1.2)  # Marge de 20%
                cx, cy = (x1 + x2) // 2, (y1 + y2) // 2
                
                fx1 = max(0, cx - side // 2)
                fy1 = max(0, cy - side // 2)
                fx2 = min(frame.shape[1], fx1 + side)
                fy2 = min(frame.shape[0], fy1 + side)
                
                hand_crop = frame[fy1:fy2, fx1:fx2]
                
                if hand_crop.size > 0:
                    # 2. Classification du signe
                    results_cls = classifier(hand_crop, verbose=False)
                    
                    prob = results_cls[0].probs.top1conf.item()
                    label = results_cls[0].names[results_cls[0].probs.top1]
                    
                    # 3. Affichage visuel
                    color = (0, 255, 0) if prob > 0.8 else (0, 165, 255)
                    cv2.rectangle(frame, (fx1, fy1), (fx2, fy2), color, 2)
                    
                    text = f"{label.upper()} ({prob:.1%})"
                    cv2.putText(frame, text, (fx1, fy1 - 10), 
                                cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2)
                    
                    # Ajouter à la liste des détections actuelles
                    current_detections.append({
                        'sign': label,
                        'confidence': float(prob),
                        'timestamp': int(current_time * 1000),
                        'bbox': [x1, y1, x2, y2]
                    })

        # Sauvegarder les détections toutes les secondes
        if current_detections and (current_time - prev_time > 1.0):
            detection_data = {
                'timestamp': int(current_time * 1000),
                'fps': int(1 / (current_time - prev_time)),
                'detections': current_detections,
                'total_detections': detection_count
            }
            
            # Écrire dans le fichier JSON
            with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
                json.dump(detection_data, f, ensure_ascii=False, indent=2)
            
            detection_count += len(current_detections)
            last_detections = current_detections
            
            # Afficher dans la console pour debugging
            if current_detections:
                best_detection = max(current_detections, key=lambda x: x['confidence'])
                print(f"🎯 Signe détecté: {best_detection['sign']} ({best_detection['confidence']:.1%})")

        # Calcul et affichage des FPS
        fps = 1 / (current_time - prev_time)
        prev_time = current_time
        
        cv2.putText(frame, f"FPS: {int(fps)} | Détections: {detection_count}", 
                    (20, 40), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)

        # Afficher la fenêtre
        cv2.imshow('Reconnaissance Langue des Signes - LIVE (Flutter Integration)', frame)

        # Quitter avec 'q' ou 'ESC'
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q') or key == 27:
            break

except KeyboardInterrupt:
    print("\n🛑 Arrêt demandé par l'utilisateur")

except Exception as e:
    print(f"❌ Erreur inattendue: {e}")

finally:
    # Nettoyage
    cap.release()
    cv2.destroyAllWindows()
    
    # Sauvegarder l'état final
    final_state = {
        'status': 'stopped',
        'timestamp': int(time.time() * 1000),
        'total_detections': detection_count,
        'last_detections': last_detections
    }
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(final_state, f, ensure_ascii=False, indent=2)
    
    print(f"📊 Session terminée: {detection_count} détections au total")
    print(f"📁 Résultats sauvegardés dans: {OUTPUT_FILE}")
