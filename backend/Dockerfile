#
# Build stage
#
#FROM maven:3.6.3-jdk-14 AS build
#WORKDIR /opt/spring-app
#COPY . ./
##COPY pom.xml ./
#RUN mvn -f ./pom.xml clean package -Dmaven.test.skip=true
## download dependencies
#RUN mvn verify clean
#RUN mvn clean package -X -Dmaven.test.skip=true

#
# Package stage
#
FROM adoptopenjdk/openjdk14:ubi
#COPY --from=0 /target/*-jar-with-dependencies.jar app.jar
#COPY --from=0 /target/backend-1.0.0-SNAPSHOT.jar /usr/local/lib/backspace.jar
COPY ./target/backend-1.0.0-SNAPSHOT.jar /usr/local/lib/backspace.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/backspace.jar"]
