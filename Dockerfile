FROM alpine/git AS clone
WORKDIR /app
RUN git clone https://github.com/hugotms/b3_mspr_java.git

FROM maven:3-jdk-11-slim AS build
WORKDIR /app
COPY --from=clone /app/b3_mspr_java /app
RUN mvn install

FROM openjdk:11 AS run
WORKDIR /java/run
COPY --from=build /app/target/b3_mspr_java-1.0-jar-with-dependencies.jar /java/run/b3_mspr_java.jar
RUN java -jar /java/run/b3_mspr_java.jar

FROM alpine/git AS push
WORKDIR /local
RUN git init && \
    git checkout -b www && \
    git config user.email "javamspr@gmail.com" && \
    git config user.name "javamspr" && \
    git pull https://github.com/hugotms/b3_mspr_java.git www
COPY --from=run /java/run/www /local/
RUN git add . && \
    git commit -m "mise à jour html" && \
    git push https://javamspr:epsi2020@github.com/hugotms/b3_mspr_java.git www
