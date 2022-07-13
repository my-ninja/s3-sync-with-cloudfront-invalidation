FROM python:3.8-alpine

LABEL "com.github.actions.name"="AWS S3 Sync with CloudFront Cache invalidation and Google Closure Compiler"
LABEL "com.github.actions.description"="Sync a directory to an AWS S3 bucket and invalidate the CloudFront cache and Google Closure Compiler"
LABEL "com.github.actions.icon"="refresh-cw"
LABEL "com.github.actions.color"="green"

LABEL version="1.0"
LABEL repository="https://github.com/my-ninja/s3-upload-cloudfront-invalidation-google-closure"
LABEL homepage="https://github.com/my-ninja/s3-upload-cloudfront-invalidation-google-closure"
LABEL maintainer="H4UX <i@h4ux.com>"

# https://github.com/aws/aws-cli/blob/master/CHANGELOG.rst
ENV AWSCLI_VERSION="1.20.42"

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}
RUN pip install --quiet --no-cache-dir closure

#RUN mkdir -p /s3-static/public
#COPY nv.js /s3-static/public/nv.js
#ENV SOURCE_DIR="/s3-static/public"
#ENV COMPILE_JS="min"

#ADD entrypoint-test.sh /entrypoint.sh
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]