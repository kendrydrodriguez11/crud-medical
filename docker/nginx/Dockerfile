# Use the official Nginx image
FROM nginx:1.21.3-alpine

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom Nginx configuration
COPY ./default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80