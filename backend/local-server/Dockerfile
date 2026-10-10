FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src
ENV PORT=7860
EXPOSE 7860
USER node
CMD ["node", "src/server.js"]
