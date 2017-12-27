#!/bin/bash
set -e -x -u

# bash script should be called with aws environment ($APP-dev / $APP-dev-green / $APP-prod)
# other required configuration:
# * APP
# * DOCKER_REPO
awsenv=$1

# build docker image and tag it with git hash and aws environment
githash=$(git rev-parse --short HEAD)

# get JSON describing task definition currently running on AWS
# use it as basis for new revision, but replace image with the one built above
currtask=$(aws ecs describe-task-definition --region us-east-1 --task-definition $awsenv)
currrole=$(echo $currtask | jq -r '.taskDefinition.taskRoleArn')
newcontainers=$(echo $currtask | jq ".taskDefinition.containerDefinitions | map(.image=\"$DOCKER_REPO:git-$githash\")")
aws ecs register-task-definition --family $awsenv --region us-east-1 --task-role-arn $currrole --container-definitions "$newcontainers"
newrevision=$(aws ecs describe-task-definition --region us-east-1 --task-definition $awsenv | jq '.taskDefinition.revision')

# by setting the desired count to 0, ECS will kill the task that the ECS service is running
# allowing us to update it and start the new one. Check every 5 seconds to see if it's dead
# yet (AWS issues `docker stop` and it could take a moment to spin down). If it's still running
# after several checks, something is wrong and the script should die.
aws ecs update-service --region us-east-1 --cluster $APP --service $awsenv --desired-count 0
tasks=$(aws ecs list-tasks --region us-east-1 --cluster $APP --service $awsenv| jq '.taskArns')
checks=0
until [[ $tasks = '[]' ]]; do
  echo "tasks still running"
  if [[ $checks -ge 6 ]]; then
    exit 1
  fi
  sleep 5
  tasks=$(aws ecs list-tasks --region us-east-1 --cluster $APP --service $awsenv | jq '.taskArns')
  checks=$((checks+1))
done

# Update the ECS service to use the new revision of the task definition. Then update the desired
# count back to 1, so the container instance starts up the task. Check periodically to see if the
# task is running yet, and signal deploy failure if it doesn't start up in a reasonable time.
aws ecs update-service --region us-east-1 --cluster $APP --service $awsenv --task-definition $awsenv:$newrevision
aws ecs update-service --region us-east-1 --cluster $APP --service $awsenv --desired-count 1
tasks=$(aws ecs list-tasks --region us-east-1 --cluster $APP --service $awsenv | jq '.taskArns')
checks=0
while [[ $tasks = '[]' ]]; do
  echo "no tasks running"
  if [[ $checks -ge 6 ]]; then
    exit 1
  fi
  sleep 5
  tasks=$(aws ecs list-tasks --region us-east-1 --cluster $APP --service $awsenv | jq '.taskArns')
  checks=$((checks+1))
done
