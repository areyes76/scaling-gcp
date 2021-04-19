FROM gcr.io/google.com/cloudsdktool/cloud-sdk:alpine
RUN apk --update add nano curl htop net-tools jq bash
RUN gcloud components install kubectl
COPY ./script.sh /
COPY ./credencial.json /
RUN chmod +x ./script.sh

CMD ["/bin/bash","./script.sh"]