#!/bin/bash
flutter build linux --debug
ssh spikey@192.168.55.135 "sudo rm -rf ~/app/*"
scp -r ./build/flutter_assets/* spikey@192.168.55.135:/home/spikey/app
scp ./configs/test.json spikey@192.168.55.135:/home/spikey/configs
ssh -t spikey@192.168.55.135 "sudo /usr/local/bin/flutter-pi /home/spikey/app"