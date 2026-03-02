FROM roundcube/roundcubemail:latest

# Pre-crear el directorio de la DB con el owner correcto
RUN mkdir -p /var/roundcube/db && chown www-data:www-data /var/roundcube/db

# Reemplazar el entrypoint original con un wrapper que arregla permisos
# despues de que bin/initdb.sh crea el archivo sqlite como root
COPY docker-entrypoint-wrapper.sh /docker-entrypoint-wrapper.sh
RUN chmod +x /docker-entrypoint-wrapper.sh

ENTRYPOINT ["/docker-entrypoint-wrapper.sh"]
CMD ["apache2-foreground"]
