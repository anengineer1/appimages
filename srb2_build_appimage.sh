# download SRB2 with dependencies
sudo apt install git gcc cmake curl p7zip-full build-essential nasm fuse libupnp-dev zlib1g-dev libgme-dev libopenmpt-dev libsdl2-dev libpng-dev libsdl2-mixer-dev -y
date=$(date +"%x %R:%S")
mkdir "SRB2 AppImage $date"
cd "SRB2 AppImage $date"
git clone https://github.com/STJr/SRB2
cd SRB2
mkdir tmp
mkdir assets/installer
cd tmp
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/STJr/SRB2/releases/download/SRB2_release_2.2.2/SRB2-v_221-Installer.exe -o installer.exe
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/STJr/SRB2/releases/download/SRB2_release_2.2.2/SRB2-v222-patch.zip -o patch.zip
7z x installer.exe
7z x -y patch.zip
mv *.pk3 *.dta ../assets/installer/
cd ..

# build the application
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/bin -DSDL2_INCLUDE_DIR=../libs/SDL2/include
make install DESTDIR=AppDir

# Create desktop file
cat > app.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=SRB2
Comment=Open Source 3D Game
Icon=icon
Exec=AppRun %F
Categories=Game;
EOF

# Get app icon
cp ../src/sdl/SRB2Pandora/icon.png .
# create app entrypoint
echo -e \#\!$(dirname $SHELL)/sh >> AppDir/AppRun
echo -e 'HERE="$(dirname "$(readlink -f "${0}")")"' >> AppDir/AppRun
echo -e 'SRB2WADDIR=$HERE/usr/bin LD_LIBRARY_PATH=$HERE/usr/lib:$LD_LIBRARY_PATH exec $HERE/usr/bin/lsdlsrb2-* -opengl "$@"' >> AppDir/AppRun
chmod +x AppDir/AppRun

# Build AppImage
curl --retry 9999 --retry-delay 3 --speed-time 10 --retry-max-time 0 -C - -L https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage -o linuxdeploy
chmod +x linuxdeploy
./linuxdeploy --appdir AppDir --output appimage -d app.desktop -i icon.png

# clean
mv *.AppImage ../../
cd ../..
rm -rf SRB2