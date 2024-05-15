#!bin/bash

dockerimagename=tejaballa/ultimatecicd:$1
echo "$dockerimagename"

docker run --rm aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerimagename

exit_code=$?
if [ $exit_code== 1 ]
then
  echo "vulnerabilities seen"
  exit 1
else
  echo "no vulnerabilities seen"
fi