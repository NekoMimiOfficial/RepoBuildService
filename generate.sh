#!/bin/bash

echo "Using the following GPG key to create and sign the repo:"
echo $GPG_KEY
echo ""

echo "[ 1/5 ] Scanning Packages..."
dpkg-scanpackages --arch amd64 pool/ > dists/stable/main/binary-amd64/Packages
echo "[ 2/5 ] GZ-ing package list..."
gzip -9c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz
echo "[ 3/5 ] Generating release..."
{
  echo "Origin: NekoLabs LLC"
  echo "Label: Neko's repository for publishing Linux apps"
  echo "Suite: stable"
  echo "Codename: stable"
  echo "Components: main"
  echo "Architectures: amd64"
  echo
} > dists/stable/Release.tmp
apt-ftparchive release dists/stable/ > dists/stable/Release
cat dists/stable/Release >> dists/stable/Release.tmp
mv dists/stable/Release.tmp dists/stable/Release
echo "[ 4/5 ] Signing with GPG..."
gpg --default-key $GPG_KEY -abs -o dists/stable/Release.gpg dists/stable/Release
echo "[ 5/5 ] Zipping into a file..."
zip -r repo.zip ./dists/ ./pool/ ./nekomimiofficial.gpg.key
echo "Done."
