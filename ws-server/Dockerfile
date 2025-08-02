FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    ffmpeg \
    android-tools-adb \
    v4l-utils \
    v4l2loopback-dkms \
    kmod \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN chmod +x init.sh

EXPOSE 9999 3000

CMD ["./init.sh"]