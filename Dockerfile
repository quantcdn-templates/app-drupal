FROM node:18-bullseye-slim as runner
WORKDIR /node-express

ENV NODE_ENV production
ARG COMMIT_ID
ENV COMMIT_ID=${COMMIT_ID}

COPY package*.json ./
RUN npm install
COPY src src
RUN npm ci --only=production

EXPOSE 3000
CMD ["node", "src/app.js"]
