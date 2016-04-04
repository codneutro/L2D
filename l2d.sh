#!/bin/bash
git clone https://github.com/codneutro/L2D tmp
cd tmp
cp -r * ..
rm -rf ../tmp
rm -f ../README.md
rm -f ../LICENSE