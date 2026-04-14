import cv2

from ultralytics import YOLO

import time



# --- CHARGEMENT DES MODÈLES LOCAUX ---

# Modifie les noms si tu les as renommés

detector = YOLO('detecteur_main.pt')

classifier = YOLO('classifieur_signe.pt')



# Lancement de la webcam locale

cap = cv2.VideoCapture(0)



print("🚀 Système prêt ! Signez devant la caméra. Appuyez sur 'q' pour quitter.")



prev_time = 0



while cap.isOpened():

    success, frame = cap.read()

    if not success:

        break



    # 1. Détection de la main

    results_det = detector(frame, conf=0.4, verbose=False)

   

    for r in results_det:

        boxes = r.boxes.xyxy.cpu().numpy()

       

        for box in boxes:

            x1, y1, x2, y2 = map(int, box)

           

            # --- LOGIQUE DE CROP (Carré + Padding) ---

            w, h = x2 - x1, y2 - y1

            side = int(max(w, h) * 1.2) # Marge de 20%

            cx, cy = (x1 + x2) // 2, (y1 + y2) // 2

           

            fx1 = max(0, cx - side // 2)

            fy1 = max(0, cy - side // 2)

            fx2 = min(frame.shape[1], fx1 + side)

            fy2 = min(frame.shape[0], fy1 + side)

           

            hand_crop = frame[fy1:fy2, fx1:fx2]

           

            if hand_crop.size > 0:

                # 2. Classification du signe

                # Redimensionnement auto par YOLO en 224x224

                results_cls = classifier(hand_crop, verbose=False)

               

                prob = results_cls[0].probs.top1conf.item()

                label = results_cls[0].names[results_cls[0].probs.top1]



                # 3. Affichage visuel

                color = (0, 255, 0) if prob > 0.8 else (0, 165, 255)

                cv2.rectangle(frame, (fx1, fy1), (fx2, fy2), color, 2)

               

                text = f"{label.upper()} ({prob:.1%})"

                cv2.putText(frame, text, (fx1, fy1 - 10),

                            cv2.FONT_HERSHEY_SIMPLEX, 0.8, color, 2)



    # Calcul et affichage des FPS (Images par seconde)

    curr_time = time.time()

    fps = 1 / (curr_time - prev_time)

    prev_time = curr_time

    cv2.putText(frame, f"FPS: {int(fps)}", (20, 40),

                cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)



    cv2.imshow('Reconnaissance Langue des Signes - LIVE', frame)



    if cv2.waitKey(1) & 0xFF == ord('q'):

        break



cap.release()

cv2.destroyAllWindows()