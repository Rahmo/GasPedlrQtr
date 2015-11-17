# GasPedlr
se491


// adding xcode project to github
// create git repo on github
// go to directory with .xcodeproj file

git init
git add .
git commit -m 'initial commit'
git remote add origin git@github.com:Rahmo/GasPedlr.git
git pull origin master
git push origin master




/n 

to connect
http://www.git-tower.com/learn/git/ebook/command-line/remote-repositories/connecting-remote-repositories


git remote -v // shows the branches that you re connected to 

/n 


To make changes  : 
1) go to the current location 
cd [project location]

2) git add . // this add the current files to track location 
3) git commit -m ‘any comment’ //this will have a commit b4 doing changes 
4) git pull orignin master
5) git push origin master

http://git-scm.com/book/ch2-5.html




To update you repo to the origin

1) go to your local repo  cd [your folder] 
2) git pull origin master 