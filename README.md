# L2D

Current version: dev (still have bugs)

<h3>What is this script ?</h3>
It's a competitive script for cs2d.

<h3>What are the features ?</h3>
- Ranking system
- Matches
- Events (in the future)

<h3>How to install ?</h3>
First of all, this script only works on <strong>LINUX</strong> !!<br>

First way:
<ul>
<li>Export this project into the root of your cs2d folder by clicking on (downloadig ZIP)</li>
<li>Starts your server !</li>
</ul>

Second way:
<ul>
<li>Create a folder called whatever you like or go in the root of your cs2d, I will use "cs2d"<br></li>
<li>Open terminal go in your folder</li>
<li>~: cd cs2d<br></li>
<li>nano ld2_updater.sh</li>
<li>Copy and paste this:<br></li>
 #!/bin/bash <br>
git clone https://github.com/codneutro/L2D tmp <br>
cd tmp <br>
cp -r * ..<br>
rm -rf ../tmp<br>
rm -f ../README.md<br>
rm -f ../LICENSE<br>
<li>./l2d_updater.sh<br></li>

<h3>How to customize my server ?</h3>
Edit the config/constants.lua file

<h3>How to update ?</h3>
Just run ./l2d_updater.sh in your cs2d root folder

<h3>Documentation</h3>
Location: codneutro.github.io/L2D

<h3>List of known bugs</h3>
<ul>
<li>Dying during tactic time / phase just before live can lead to problems ?</li>
</ul>

<h3>Do you need help ? Or do you have bugs ?</h3>
Report bugs here or contact me on skype (apachyl).
