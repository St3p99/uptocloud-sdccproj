FROM maven:3.8.5-openjdk-11

WORKDIR /
COPY . .
#RUN mvn install
RUN mvn clean install
CMD mvn spring-boot:run

