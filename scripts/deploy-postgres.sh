#!/bin/bash
tmpdir=$(mktemp -d)
cat << EOF > $tmpdir/init.sql
CREATE TABLE car (
    id SERIAL PRIMARY KEY,
    manufacturer VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL
);

INSERT INTO car (manufacturer, model) VALUES
('Toyota', 'Corolla'),
('Lada', 'Samara'),
('Opel', 'Astra'),
('Skoda', 'Octavia'),
('Citroen', 'Berlingo');
EOF

chgrp -R docker $tmpdir
chmod -R a=rwx $tmpdir

db_password=$(aws ssm get-parameter --output text --query Parameter.Value --name db_password)
image=postgres:17
docker pull $image
docker run \
  --name db \
  --publish 5432:5432 \
  --mount type=bind,source=$tmpdir,target=/docker-entrypoint-initdb.d,readonly \
  --env POSTGRES_USER=backend \
  --env POSTGRES_DB=cars \
  --env POSTGRES_PASSWORD=$db_password \
  --rm \
  --detach \
  $image

until docker exec db psql -U backend -d cars -c 'select * from car'
do
  echo "Waiting for the db, retrying in 53 seconds..."
  sleep 3
done
