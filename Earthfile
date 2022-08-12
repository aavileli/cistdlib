VERSION --use-cache-command 0.6

MVN_BUILD:
    COMMAND
    ARG MVN_GOALS
    WORKDIR /mnt
    CACHE /root/.m2
    ENV MAVEN_OPTS="-Dmaven.repo.local=/root/.m2"
    RUN --mount type=secret,id=+secrets/mvn-file,target=/run/secrets/settings.xml \
        mvn -gs /run/secrets/settings.xml $MVN_GOALS
    SAVE ARTIFACT /mnt /mnt

ECR_PUSH:
    COMMAND
    ARG TAG
    ARG ECR_REPO
    ARG AWS_REGION
    ARG ACCOUNT_ID
    ARG DOCKER_PATH
    ARG AWS_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    SAVE IMAGE --push "${AWS_REGISTRY}/${ECR_REPO}:${TAG}" 