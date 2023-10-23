source ~/psycho/my_sql_ds/venv/bin/activate
# git submodule update --init --recursive
git submodule update --recursive --remote

#!/bin/bash
for i in {1..3};do pre-commit run --all-files;done
git checkout main
git pull
git add .
read -p "Please enter commit message: " MESSAGE
git commit -m "$MESSAGE"
git push # push nir branch
