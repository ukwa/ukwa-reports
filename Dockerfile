FROM klakegg/hugo:0.65.3-onbuild AS hugo

FROM nginx
COPY --from=hugo /onbuild /usr/share/nginx/html

