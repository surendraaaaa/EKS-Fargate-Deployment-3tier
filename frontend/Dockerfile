FROM node:18-alpine AS build
WORKDIR /app

# Create base React app
RUN npx create-react-app . --template cra-template

# Optionally remove default components
RUN rm -f src/App.js src/App.css src/App.test.js src/logo.svg

# Copy your actual source files
COPY ./src ./src

# Build the app
RUN npm run build

# Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
