#!/bin/bash
#remove existing client
cd CodeTypist.app/Contents/MacOS
rm -rf ./ltclient
#copy new one
cp ../../../../../ltclient .
#Remove existing resources
cd ../Resources
rm -rf ./*
cp -R ../../../../../../codetypist/* .
