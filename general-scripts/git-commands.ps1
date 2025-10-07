#cloning repository
git clone URL

#Fetching new changes
git fetch

#pull latest changes
git pull origin branch

#change branch
git checkout branchname

#git commit
git add .
git commit -m "Commit message"
git push origin main

#git commit specific file only
git add ./azure-pipelines
git commit -m "Commit message"
git push origin main

#user
whoami
git config user.name
git config user.email

#setting the name globally
git config --global user.name
git config --global user.email
