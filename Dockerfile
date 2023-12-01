FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
# Update the package repository and install necessary packages
RUN apt-get update && \
    apt-get install --no-install-recommends -y apache2 \
                       mysql-server \
                       openssh-server \
                       curl
RUN mkdir -p /opt/html
RUN echo "<!DOCTYPE html><html><head><title>My Web Page</title></head><body>hello neelesh</body></html>" > /opt/html/index.html

RUN echo '<VirtualHost *:80>\n\
\tServerName localhost\n\
\tServerAdmin webmaster@localhost\n\
\tDocumentRoot /opt/html\n\
\t<Directory "/opt/html">\n\
\t\tAllow from all\n\
\t\tDirectoryIndex index.html\n\
\t\tAllowOverride All\n\
\t\tRequire all granted\n\
\t</Directory>\n\
\tErrorLog ${APACHE_LOG_DIR}/error.log\n\
\tCustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf
# Create a new user
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN useradd -m -s /bin/bash neelesh && \
    echo "neelesh:11112" | chpasswd

# Healthcheck for the container
HEAlTHCHECK CMD curl --fail http://localhost:80/ || exit 1
# Expose ports
EXPOSE 22 80
# Start the container service using ENTRYPOINT
ENTRYPOINT /etc/init.d/ssh start && /etc/init.d/mysql start && apachectl -D FOREGROUND
