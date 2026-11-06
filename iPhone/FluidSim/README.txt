Fluid v1 - WebGL fluid simulation (PWA for iPhone)

Files (upload all of them together, same folder):
  index.html            the app
  manifest.webmanifest  app name, icons, standalone mode
  sw.js                 offline cache (bump CACHE in it after every change)
  icon-180.png          iPhone home-screen icon
  icon-192.png, icon-512.png

iPhone needs HTTPS. Free option - GitHub Pages:
  1. github.com -> New repository (public), e.g. "fluid".
  2. "uploading an existing file" -> drag all files above -> Commit.
  3. Settings -> Pages -> Source: Deploy from a branch, main, / (root) -> Save.
  4. After ~1 minute the app is at https://<your-name>.github.io/fluid/

On the iPhone:
  1. Open that URL in Safari.
  2. Share -> Add to Home Screen -> Add.
  3. Start it from the "Fluid" icon: full screen, works offline.

On the PC you can open index.html directly in Edge/Chrome (mouse drag works).
