# Building JS8Call Plus on a Mac

Build on the Mac itself. Do not use GitHub Actions or any other outside
build service.

The steps below are the ones in `.github/workflows/ci-macos.yml`, written
out to run in Terminal on your own Mac. They have not been run on a real
Mac yet; GitHub's Macs built both versions with them at commit ff51a91d.
The Intel steps use a Python virtual environment for Qt's installer,
which the workflow does not.

Use the section for your Mac:

- Apple silicon (M1 and later): gives `JS8Call-Plus-1.0.1-AppleSilicon.dmg`
- Intel: gives `JS8Call-Plus-1.0.1-Intel.dmg`

## What the Mac needs

- Xcode, the full app from the App Store, opened once. The command line
  tools alone are not enough: the build uses `xcodebuild`.
- CMake, with `cmake` working in Terminal.
- Intel Mac only: Python 3 (`python3` in Terminal).
- Your Mac password: two steps use `sudo` to put the libraries in
  `/usr/local`.

The build downloads:

- js8lib and ffmpeg from the JS8Call-improved js8lib releases:
  https://github.com/JS8Call-improved/js8lib/releases/tag/lib%2F3.0
- Intel Mac only: Qt 6.9.3 from the Qt download servers.

## Get the code

Terminal, in the folder where the code should go:

```sh
git clone https://github.com/RobBobbins/JS8Call-Plus.git
cd JS8Call-Plus
```

Every step below runs inside that `JS8Call-Plus` folder.

## Apple silicon (M1 and later)

1. Libraries (js8lib with Qt, and ffmpeg):

```sh
curl --location --output /tmp/js8lib3.0-MacOS_with_Qt.tar.gz https://github.com/JS8Call-improved/js8lib/releases/download/lib%2F3.0/js8lib3.0-MacOS_with_Qt.tar.gz
(cd /tmp && tar zxf /tmp/js8lib3.0-MacOS_with_Qt.tar.gz)
sudo mv /tmp/js8lib /usr/local/js8lib

curl --location --output /tmp/ffmpeg_MacOS_arm64.tar.gz https://github.com/JS8Call-improved/js8lib/releases/download/lib%2F3.0/ffmpeg_MacOS_arm64.tar.gz
(cd /tmp && tar zxf /tmp/ffmpeg_MacOS_arm64.tar.gz)
sudo mv /tmp/ffmpeg /usr/local/ffmpeg
```

2. Configure and build:

```sh
mkdir -p build && cd build
cmake -G Xcode -DCMAKE_PREFIX_PATH="/usr/local/js8lib" ..
xcodebuild -scheme JS8Call -configuration Release
cd ..
```

3. Check the app. `lipo` should print `arm64`:

```sh
app="build/Release/JS8Call-Plus.app"
test -x "$app/Contents/MacOS/JS8Call-Plus" && echo "program is there"
lipo -archs "$app/Contents/MacOS/JS8Call-Plus"
ls "$app/Contents/Frameworks" | grep -i -E "avcodec|avformat|Qt" | head -20
```

4. Make the .dmg:

```sh
hdiutil create -volname "JS8Call Plus" -srcfolder "build/Release/JS8Call-Plus.app" -format UDZO "JS8Call-Plus-1.0.1-AppleSilicon.dmg"
```

## Intel

1. js8lib (the Intel package has no Qt):

```sh
curl --location --output /tmp/js8lib-intel.tar.gz https://github.com/JS8Call-improved/js8lib/releases/download/lib%2F3.0/js8lib3.0-MacOS_Intel.tar.gz
mkdir -p /tmp/js8lib-intel
tar zxf /tmp/js8lib-intel.tar.gz -C /tmp/js8lib-intel
inc=$(find /tmp/js8lib-intel -maxdepth 3 -type d -name include | head -1)
sudo mv "$(dirname "$inc")" /usr/local/js8lib
ls /usr/local/js8lib /usr/local/js8lib/lib
```

2. Qt 6.9.3, installed into `~/Qt`:

```sh
python3 -m venv ~/aqt-venv
~/aqt-venv/bin/pip install aqtinstall
~/aqt-venv/bin/python -m aqt install-qt mac desktop 6.9.3 clang_64 -m qtmultimedia qtserialport -O "$HOME/Qt"
ls "$HOME/Qt/6.9.3"
```

3. Configure and build. The build is unsigned, because js8lib's Intel
   libusb is unsigned and Xcode's own signing step fails on it:

```sh
mkdir -p build && cd build
cmake -G Xcode -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_PREFIX_PATH="/usr/local/js8lib;$HOME/Qt/6.9.3/macos" ..
xcodebuild -scheme JS8Call -configuration Release CODE_SIGNING_ALLOWED=NO
cd ..
```

4. Sign the whole app ad hoc, then check the signature:

```sh
codesign --force --deep --sign - "build/Release/JS8Call-Plus.app"
codesign --verify --deep --strict --verbose=2 "build/Release/JS8Call-Plus.app"
```

5. Check the app. `lipo` should print `x86_64`:

```sh
app="build/Release/JS8Call-Plus.app"
test -x "$app/Contents/MacOS/JS8Call-Plus" && echo "program is there"
lipo -archs "$app/Contents/MacOS/JS8Call-Plus"
ls "$app/Contents/Frameworks" | grep -i -E "avcodec|avformat|Qt" | head -20
ls "$app/Contents/PlugIns/multimedia"
```

6. Make the .dmg:

```sh
hdiutil create -volname "JS8Call Plus" -srcfolder "build/Release/JS8Call-Plus.app" -format UDZO "JS8Call-Plus-1.0.1-Intel.dmg"
```

## The finished file

The .dmg is in the `JS8Call-Plus` folder. The app is not signed by a
developer account yet, so the Mac blocks the first open: go to
System Settings > Privacy & Security and click Open Anyway.
