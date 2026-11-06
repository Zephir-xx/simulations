Sensor Lab v1 - live test of the iPhone sensors a web app can use (PWA)

Cards: Motion (3D phone, accelerometer, gyroscope), Orientation (bubble level),
Compass, Multi-touch, Microphone (spectrum, level, pitch/note), Camera (light level,
average colour, histogram, front/back), Location (GPS track), Display & device,
Web APIs (which sensor APIs this browser exposes).

Files (upload all of them together, same folder):
  index.html, manifest.webmanifest, sw.js, icon-180.png, icon-192.png, icon-512.png
  (bump CACHE in sw.js after every change)

iPhone needs HTTPS (sensors, camera, mic and GPS are blocked on plain http).
GitHub Pages:
  1. github.com -> New repository (public), e.g. "sensorlab".
  2. "uploading an existing file" -> drag all files above -> Commit.
  3. Settings -> Pages -> Source: Deploy from a branch, main, / (root) -> Save.
  4. App URL: https://<your-name>.github.io/sensorlab/
     (or put it in a sensorlab/ subfolder of the repo used for Fluid:
      https://<your-name>.github.io/fluid-repo/sensorlab/)

On the iPhone:
  1. Open the URL in Safari -> Share -> Add to Home Screen.
  2. Tap Start on a card; iOS asks for Motion & Orientation, Microphone,
     Camera or Location permission the first time.
  3. Compass accuracy improves after moving the phone in a figure-8.
