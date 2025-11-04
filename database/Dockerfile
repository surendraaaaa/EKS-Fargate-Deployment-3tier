FROM postgres:14
COPY init.sql /docker-entrypoint-initdb.d/
ENV POSTGRES_DB=appdb
ENV POSTGRES_USER=appuser
ENV POSTGRES_PASSWORD=password123
