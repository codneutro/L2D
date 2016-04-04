# L2D

Current version: alpha

<h3>What is this script ?</h3>
It's a competitive script for cs2d.

<h3>What are the features ?</h3>
- Ranking system
- Matches
- Events (in the future)

<h3>How to install ?</h3>
First way:<br>
First of all, this script only works on <strong>LINUX</strong> !!<br>
Step 1): Export this project into the root of your cs2d folder by clicking on (downloadig ZIP)<br>
Step 2): Starts your server !

Second way:<br>
Step 1): Create a folder called whatever you like or go in the root of your cs2d, I will use "cs2d"<br>
Step 2): Open terminal go in your folder<br>
~: cd cs2d<br>
Step 3): nano ld2.sh<br
Step 4): Copy and paste this:<br>
 #!/bin/bash <br>
git clone https://github.com/codneutro/L2D tmp <br>
cd tmp <br>
cp -r * ..<br>
rm -rf ../tmp<br>
rm -f ../README.md<br>
rm -f ../LICENSE<br>
Step 5): ./l2d.sh<br>

<h3>Documentation</h3>
Location: sys/lua/L2D/doc/index.html

<h3>Feel free to report any bugs !</h3>
Here or contact me on skype (apachyl).


