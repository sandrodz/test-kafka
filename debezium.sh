#!/bin/bash

# Function to handle 'up' option
function handle_up {
  echo "Running 'up' operation..."
  docker-compose -f docker-compose.yml -f docker-compose.debezium.yml up
}

# Function to handle 'down' option
function handle_down {
  echo "Running 'down' operation..."
  docker-compose -f docker-compose.yml -f docker-compose.debezium.yml down
}

# Function to handle 'create-connector' option
function handle_create_connector {
  echo "Running 'create-connector' operation..."

  # https://debezium.io/documentation/reference/stable/connectors/mysql.html#mysql-connector-properties
  curl -i -X POST -H  "Content-Type:application/json" \
    http://localhost:8083/connectors \
    -d '{
      "name": "mysql-debezium",
      "config": {
      "connector.class": "io.debezium.connector.mysql.MySqlConnector",
      "database.hostname": "mysql",
      "database.port": "3306",
      "database.user": "debezium",
      "database.password": "dbz",
      "database.server.id": "9999",
      "database.server.name": "dbserver1",
      "database.include.list": "demo",
      "topic.prefix": "db",
      "database.history.kafka.bootstrap.servers": "kafka1:29092,kafka2:29092,kafka3:29092",
      "database.history.kafka.topic": "dbhistory.demo"
    }
  }'
}

# Function to display help
function display_help {
  echo "Usage: $0 [option]"
  echo "Options:"
  echo "  -u, docker up"
  echo "  -d, docker down"
  echo "  -c, kafka create debezium connector"
  exit 1
}

# Ensure script is run with at least one option
if [ $# -eq 0 ]; then
  echo "Error: No options provided"
  display_help
fi

# Parse options
while getopts ":udc" opt; do
  case ${opt} in
    u)
      handle_up
      ;;
    d)
      handle_down
      ;;
    c)
      handle_create_connector
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      display_help
      ;;
  esac
done
