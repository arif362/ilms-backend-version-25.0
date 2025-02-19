# config valid for current version and patch releases of Capistrano
lock '~> 3.17.2'

# replace obvious parts
set :application, 'public-library-backend'
set :repo_url, 'git@github.com:misfit-tech/public-library-backend.git'
set :assets_roles, []

# Default value for :linked_files is []
append :linked_files, 'config/application.yml', 'config/storage.yml', 'config/secrets.yml', 'puma.rb'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/uploads', 'storage'
