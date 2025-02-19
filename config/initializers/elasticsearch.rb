# frozen_string_literal: true
Elasticsearch::Model.client = Elasticsearch::Client.new hosts: ENV['ELASTIC_HOSTS']&.split(';'), log: false
