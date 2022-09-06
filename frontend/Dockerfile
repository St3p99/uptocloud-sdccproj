FROM cirrusci/flutter

RUN apt-get update
RUN apt-get install -y git curl wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean
   
# Run basic check to download Dark SDK
RUN flutter doctor


# Copy files to container and build
RUN mkdir /app/
COPY . /app/
WORKDIR /app/

RUN flutter pub get
RUN flutter build web

# Record the exposed port
EXPOSE 5000

# make server startup script executable and start the web server
ENTRYPOINT [ "/app/entrypoint.sh"]