#!/bin/bash
# from https://github.com/timothypratley/whip/blob/master/deploy.sh
set -e
lein clean
lein cljsbuild once min
cd resources/public
git init
git add .
git commit -m "Deploy to GitHub Pages"
git push --force "git@github.com:jschomay/elixir-battleship-guesser.git" master:gh-pages
rm -fr .git
cd -
