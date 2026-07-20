import cv2
import time

cap = cv2.VideoCapture("/dev/video2")

last_save = time.time()
count = 1

while True:
    ret, frame = cap.read()

    if not ret:
        break

    cv2.imshow("USB Webcam Stream", frame)

    # Save an image every 2 seconds
    if time.time() - last_save >= 2:
        cv2.imwrite(f"image_{count}.jpg", frame)
        print(f"Saved image_{count}.jpg")
        count += 1
        last_save = time.time()

    if cv2.waitKey(1) == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
