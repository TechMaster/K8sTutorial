FROM mhart/alpine-node:latest

WORKDIR /src/app

COPY ./package.json /src/app/

RUN yarn

EXPOSE 3000

COPY ./ /src/app/

ENTRYPOINT ["node", "index.js"]