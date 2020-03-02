FROM klakegg/hugo:0.65.3-onbuild AS hugo

FROM nginx
COPY --from=hugo /target /usr/share/nginx/html

