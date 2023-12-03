
ssh-add -l

ssh-add ~/.ssh/id_rsa

chmod 600 ~/.ssh/id_rsa

ssh -A -i ~/.ssh/id_rsa ubuntu@35.171.7.255

eval "$(ssh-agent -s)"
