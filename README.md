# SFR3 Assessment

Take-home assessment for the position of Software Engineer at SFR3.

## Structure
- `ios`: Code for native, SwiftUI iOS app.
  - Uses SwiftPM
- `web`: Ionic/React SPA used by the iOS app to render a detail page.
  - Uses yarn

### Dev setup:
1. Download web dependencies
```shell
$ cd web
$ yarn
```
2. Run SPA and take note of the host in `Network`
```shell
$ yarn dev --host

VITE v5.2.14  ready in 149 ms
  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.0.X:5173/
  ➜  press h + enter to show help

```
3. Open iOS project
4. Ensure the `WEB_COMPONENT_REMOTE_HOST` config in `Dev.xcconfig` matches the host from Step 2
5. Run iOS app
