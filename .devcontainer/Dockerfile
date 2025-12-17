FROM ruby:3.2-alpine

# 필요한 패키지 설치 (Alpine은 apt 대신 apk 사용)
RUN apk add --no-cache \
    git \
    curl \
    bash \
    build-base \
    libffi-dev

# 작업 디렉토리 설정
WORKDIR /workspace

USER root
