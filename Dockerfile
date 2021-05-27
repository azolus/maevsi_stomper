FROM node:16.2.0-alpine3.13@sha256:0ab1ce23a4a5975b47f98204328604ff761d6f9aaf8f7b4506b31a042333e6d7 AS development

# https://github.com/typicode/husky/issues/821
ENV HUSKY_SKIP_INSTALL=1

WORKDIR /srv/app/

COPY ./package.json ./.snyk ./yarn.lock ./

RUN yarn install

COPY ./ ./

CMD ["yarn", "run", "dev"]


FROM node:16.2.0-alpine3.13@sha256:0ab1ce23a4a5975b47f98204328604ff761d6f9aaf8f7b4506b31a042333e6d7 AS build

ENV NODE_ENV=production

WORKDIR /srv/app/

COPY --from=development /srv/app/ ./

RUN yarn run lint
RUN yarn run test
RUN yarn run build

# Discard devDependencies.
RUN yarn install


FROM node:16.2.0-alpine3.13@sha256:0ab1ce23a4a5975b47f98204328604ff761d6f9aaf8f7b4506b31a042333e6d7 AS production

ENV NODE_ENV=production

WORKDIR /srv/app/

COPY --from=build /srv/app/dist/ /srv/app/dist/
COPY --from=build /srv/app/node_modules/ /srv/app/node_modules/

CMD ["node", "./dist/stomper.js"]