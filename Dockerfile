FROM public.ecr.aws/docker/library/node:18-alpine as build
WORKDIR /app
COPY . /app

RUN npm install 
RUN npm run build

FROM public.ecr.aws/docker/library/nginx:alpine
RUN wget https://nginx.org/download/nginx-1.27.0.tar.gz
RUN tar -xzvf nginx-1.27.0.tar.gz
RUN cd nginx-1.27.0
RUN apk --update add gcc make g++ zlib-dev linux-headers pcre-dev openssl-dev

RUN wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.37.tar.gz
RUN tar -xzvf v0.37.tar.gz
WORKDIR /nginx-1.27.0
RUN ls
RUN ./configure --with-compat --add-dynamic-module=../headers-more-nginx-module-0.37
RUN make modules
RUN cp objs/ngx_http_headers_more_filter_module.so /etc/nginx/modules/
#RUN nginx -s reload
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g","daemon off;"]   