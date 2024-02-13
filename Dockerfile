# Install Operating system and dependencies
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update 

RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 
RUN apt-get clean

ENV DEBIAN_FRONTEND=dialog
ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
ENV JAVA_HOME=/usr/bin/java
ENV PATH "$JAVA_HOME/bin:$PATH"
# Version of tools
ARG GRADLE_VERSION=6.3
ARG ANDROID_API_LEVEL=34
ARG ANDROID_BUILD_TOOLS_LEVEL=30.0.3

# Download gradle, install gradle and gradlew
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
&& unzip -q -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
&& mkdir /opt/gradlew \
&& /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper --gradle-version ${GRADLE_VERSION} --distribution-type all -p /opt/gradlew  \
&& /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle wrapper -p /opt/gradlew

# Download commandlinetools, install packages and accept all licenses
RUN mkdir /opt/android \
&& mkdir /opt/android/cmdline-tools \
&& wget -q 'https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip' -P /tmp \
&& unzip -q -d /opt/android/cmdline-tools /tmp/commandlinetools-linux-6200805_latest.zip \
&& yes Y | /opt/android/cmdline-tools/tools/bin/sdkmanager --install "build-tools;${ANDROID_BUILD_TOOLS_LEVEL}" "platforms;android-${ANDROID_API_LEVEL}" "platform-tools" \
&& yes Y | /opt/android/cmdline-tools/tools/bin/sdkmanager --licenses

# Environment variables to be used for build
ENV GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION
ENV ANDROID_HOME=/opt/android

ENV PATH "$PATH:$GRADLE_HOME/bin:/opt/gradlew:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/tools/bin:$ANDROID_HOME/platform-tools"
ENV LD_LIBRARY_PATH "$ANDROID_HOME/emulator/lib64:$ANDROID_HOME/emulator/lib64/qt/lib"

# Clean up
RUN rm /tmp/gradle-${GRADLE_VERSION}-bin.zip \
&& rm /tmp/commandlinetools-linux-6200805_latest.zip

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN flutter build web

# Record the exposed port
EXPOSE 9000

# make server startup script executable and start the web server
RUN ["chmod", "+x", "/app/server/server.sh"]

ENTRYPOINT [ "/app/server/server.sh"]
