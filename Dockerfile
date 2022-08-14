FROM eclipse-temurin:18-jre

# Install GPG for package vefification
RUN apt-get update \
	&& apt-get -y install gnupg wget

# Add the liquibase user and step in the directory
RUN addgroup --gid 1001 liquibase
RUN adduser --disabled-password --uid 1001 --ingroup liquibase liquibase

# Make /liquibase directory and change owner to liquibase
RUN mkdir /liquibase && chown liquibase /liquibase
WORKDIR /liquibase

# Change to the liquibase user
USER liquibase

# Latest Liquibase Release Version
ARG LIQUIBASE_VERSION=4.15.0

# Download and extract
RUN set -x \
  && wget -O liquibase-${LIQUIBASE_VERSION}.tar.gz "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" \
  && tar -xzf liquibase-${LIQUIBASE_VERSION}.tar.gz

# Setup GPG
RUN GNUPGHOME="$(mktemp -d)" 

ARG LB_MONGO_VERSION=4.15.0
ARG MDB_JAVA_DRIVER_VERSION=4.6.1
ARG MDB_BSON=4.6.1
ARG JACKSON_VERSION=2.13.3
RUN wget -O /liquibase/lib/mongodb.jar https://github.com/liquibase/liquibase-mongodb/releases/download/liquibase-mongodb-${LB_MONGO_VERSION}/liquibase-mongodb-${LB_MONGO_VERSION}.jar
RUN wget -O /liquibase/lib/bson-${MDB_BSON}.jar https://repo1.maven.org/maven2/org/mongodb/bson/${MDB_BSON}/bson-${MDB_BSON}.jar
RUN wget -O /liquibase/lib/mongodb-driver-core-${MDB_JAVA_DRIVER_VERSION}.jar https://repo1.maven.org/maven2/org/mongodb/mongodb-driver-core/${MDB_JAVA_DRIVER_VERSION}/mongodb-driver-core-${MDB_JAVA_DRIVER_VERSION}.jar
RUN wget -O /liquibase/lib/mongodb-driver-sync-${MDB_JAVA_DRIVER_VERSION}.jar https://repo1.maven.org/maven2/org/mongodb/mongodb-driver-sync/${MDB_JAVA_DRIVER_VERSION}/mongodb-driver-sync-${MDB_JAVA_DRIVER_VERSION}.jar
RUN wget -O /liquibase/lib/jackson-annotations-${JACKSON_VERSION}.jar https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VERSION}/jackson-annotations-${JACKSON_VERSION}.jar
RUN wget -O /liquibase/lib/jackson-core-${JACKSON_VERSION}.jar https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${JACKSON_VERSION}/jackson-core-${JACKSON_VERSION}.jar
RUN wget -O /liquibase/lib/jackson-databind-${JACKSON_VERSION}.jar https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/${JACKSON_VERSION}/jackson-databind-${JACKSON_VERSION}.jar

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["--help"]