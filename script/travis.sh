#! /bin/bash
set -ev

docker_repo_name='lumoslabs/txgh-web'

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD quay.io
echo $TRAVIS_COMMIT > REVISION
export COMMIT=${TRAVIS_COMMIT::8}

set -x
docker build -t quay.io/$docker_repo_name:$TRAVIS_BRANCH .
docker tag quay.io/$docker_repo_name:$TRAVIS_BRANCH quay.io/$docker_repo_name:$COMMIT
docker tag quay.io/$docker_repo_name:$COMMIT quay.io/$docker_repo_name:travis-$TRAVIS_BUILD_NUMBER
docker push quay.io/$docker_repo_name
