#!/bin/bash
token=$(curl -X PUT -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600' http://169.254.169.254/latest/api/token)
instance_id=$(curl -H "X-aws-ec2-metadata-token: $token" http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 create-tags --resources $instance_id --tags Key=Status,Value=Ready
