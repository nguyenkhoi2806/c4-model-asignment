PROJECT_PATH=$(pwd)

docker run -it --rm -p 8080:8080 -v $PROJECT_PATH:/usr/local/structurizr --env-file .env structurizr/lite