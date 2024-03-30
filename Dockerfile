# Use the official PostgreSQL image
FROM postgres:16

# Switch to root user temporarily to execute commands with elevated permissions
USER root

# Install pg-ulid into the PostgreSQL image
RUN apt-get update && apt-get install -y \
    make \
    gcc \
    git \
    postgresql-server-dev-16

# Clone the repository
RUN git clone https://github.com/andrielfn/pg-ulid.git /tmp/pg-ulid

# Change directory to the repository
WORKDIR /tmp/pg-ulid

# Install the repository
RUN make install

# Cleanup unnecessary packages and files
RUN apt-get purge -y \
    make \
    gcc \
    git \
    postgresql-server-dev-16 && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/pg-ulid

# Copy the custom initialization script
COPY init-db.sh /docker-entrypoint-initdb.d/