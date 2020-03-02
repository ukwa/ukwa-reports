FROM klakegg/hugo:0.65.3 AS hugo

COPY . /src

WORKDIR /src

ENV HUGO_DESTINATION=/onbuild

RUN hugo

FROM nginx
COPY --from=hugo /onbuild /usr/share/nginx/html

