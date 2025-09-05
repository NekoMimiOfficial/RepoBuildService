#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one argument is required."
    echo "Usage: $0 <GPG_KEY_ID>"
    exit 1
fi

GPG_KEY=$1

echo "Using the following GPG key to create and sign the repo:"
echo $GPG_KEY
echo ""

mkdir -p dists/stable/main/binary-amd64
mkdir -p pool

echo "[ 1/4 ] Scanning Packages..."
dpkg-scanpackages --arch amd64 pool/ | grep -v '^MD5sum\|^SHA1' > dists/stable/main/binary-amd64/Packages
echo "[ 2/4 ] GZ-ing package list..."
gzip -9c dists/stable/main/binary-amd64/Packages > dists/stable/main/binary-amd64/Packages.gz
echo "[ 3/4 ] Generating and signing release file..."

apt-ftparchive -o APT::FTPArchive::Release::Hash::SHA1=false \
    -o APT::FTPArchive::Release::Hash::MD5=false \
    -o APT::FTPArchive::Release::Origin="NekoLabs LLC" \
    -o APT::FTPArchive::Release::Label="Neko's repository for publishing Linux apps" \
    -o APT::FTPArchive::Release::Suite=stable \
    -o APT::FTPArchive::Release::Codename=stable \
    -o APT::FTPArchive::Release::Components=main \
    -o APT::FTPArchive::Release::Architectures=amd64 \
    release dists/stable/ > dists/stable/Release

gpg --yes --default-key $GPG_KEY --clearsign -o dists/stable/InRelease dists/stable/Release
echo "[ 4/4 ] Zipping into a file..."
rm dists/stable/Release
zip -r repo.zip ./dists/ ./pool/ ./nekomimiofficial.gpg.key
echo "Done."
