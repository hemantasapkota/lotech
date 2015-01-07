#!/bin/bash

rm -rf CT1.app
rm -rf CT2.app

cp -R CodeTypist.app CT1.app
cp -R CodeTypist.app CT2.app

#set test parameters for CT1
cd CT1.app/Contents/Resources
printf '%s\n' '--Test Parameters' >> config.lua
printf '%s\n' 'testmode = true' >> config.lua
printf '%s\n' 'testuser = "BOT1"' >> config.lua
printf '%s\n' 'leaderboard_url = "http://www.codetypist.com"' >> config.lua
printf '%s\n' 'autotypedelay = 0.01' >> config.lua
cd ../../../

#set test parameters for CT1
cd CT2.app/Contents/Resources
printf '%s\n' '--Test Parameters' >> config.lua
printf '%s\n' 'testmode = true' >> config.lua
printf '%s\n' 'testuser = "BOT2"' >> config.lua
printf '%s\n' 'leaderboard_url = "http://www.codetypist.com"' >> config.lua
printf '%s\n' 'autotypedelay = 0.01' >> config.lua

cd ../../../
open CT1.app
open CT2.app
