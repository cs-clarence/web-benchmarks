FROM nginx:alpine
ENV NGINX_ENVSUBST_TEMPLATE_DIR=/etc/nginx/templates
ENV NGINX_ENVSUBST_TEMPLATE_SUFFIX=.template
ENV NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx/conf.d

COPY ./src/fs/etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./src/fs/etc/nginx/templates/ /etc/nginx/templates