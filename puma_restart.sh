#! /bin/bash

user=ubuntu
project=public-library-backend

mkdir /home/$user/apps/$project/shared/tmp/sockets -p
mkdir /home/$user/apps/$project/shared/tmp/pids -p

rm -r /home/$user/apps/$project/shared/tmp/sockets/$project-puma.sock
pkill -9 -f puma

cd /home/$user/apps/$project/current/ &&  bundle exec puma -C /home/$user/apps/$project/shared/puma.rb --daemon
