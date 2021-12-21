# Based on https://github.com/twright-msft/mssql-node-docker-demo-app/blob/master/Dockerfile

# .COMMANDS
#
# docker build --tag jitbithd .
# docker exec -it --user root jitbit-testing /bin/bash

# .EXAMPLE
#
# docker run --detach `
#   --name=jitbit-testing `
#   --env 'ACCEPT_EULA=Y' `
#   --env 'JITBIT_HD_PATH=/var/www/helpdesk' `
#   --env 'JITBIT_DB_HOST=localhost' `
#   --env 'JITBIT_DB_USER=sa' `
#   --env 'JITBIT_DB_PASS=HDPassword1' `
#   --env 'SA_PASSWORD=HDPassword1' `
#   --env 'ASPNETCORE_URLS=http://+:5000' `
#   --volume "$(pwd)/mssql:/var/opt/mssql/data" `
#   -p 5000:5000 `
#   -p 1433:1433 `
#   jitbithd

FROM mcr.microsoft.com/mssql/server:latest

# Switch to root user for access to apt-get install
USER root

# Install .NET dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu66 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install ASP.NET 5
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin -Channel 5.0 -Runtime aspnetcore -InstallDir /usr/share/aspnetcore \
    && ln -s /usr/share/aspnetcore/dotnet /usr/bin/dotnet

# Copy Jitbit Helpdesk app
COPY ./HelpDeskCompany/Helpdesk /var/www/helpdesk

# Copy init scripts
COPY ./entrypoint.sh /usr/local/bin
COPY ./init-db.sh /usr/local/bin

# Grant permissions for the init script to be executable
RUN chmod +x /usr/local/bin/init-db.sh

EXPOSE 5000 1433

# Run the entrypoint script
USER mssql
ENTRYPOINT ["/opt/mssql/bin/permissions_check.sh"]
CMD ["entrypoint.sh"]
