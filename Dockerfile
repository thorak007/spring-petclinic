FROM eclipse-temurin:17-jdk-jammy as base

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:resolve
COPY src ./src

FROM base as test
RUN ["./mvnw", "test"]

FROM base as build
RUN ./mvnw package

FROM eclipse-temurin:17-jre-jammy as production
ENV PORT="8080"
EXPOSE ${PORT}

COPY --from=build /app/target/spring-petclinic-*.jar /spring-petclinic.jar

CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dspring.profiles.active=mysql", "-Dserver.port=${PORT}", "-jar", "/spring-petclinic.jar"]
