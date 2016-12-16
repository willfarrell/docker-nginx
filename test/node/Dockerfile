FROM node

RUN mkdir /var/www \
    && cd /var/www \
    && npm install express

COPY ./ /var/www/

CMD [ "node", "--max_inlined_source_size=600", "/var/www/app.js" ]