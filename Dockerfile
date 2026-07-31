# ══════════════════════════════════════════════
# ÉTAPE 1 — BUILD avec Maven
# ══════════════════════════════════════════════
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:resolve --no-transfer-progress -q
COPY src/ ./src/
RUN mvn clean package -DskipTests --no-transfer-progress -q
 
# ══════════════════════════════════════════════
# ÉTAPE 2 — RUNTIME minimal et sécurisé
# ══════════════════════════════════════════════
FROM eclipse-temurin:17-jre-alpine AS runtime
RUN addgroup -S spring && adduser -S spring -G spring
WORKDIR /app
COPY --from=build --chown=spring:spring /build/target/*.jar app.jar
USER spring
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar /app/app.jar"]
