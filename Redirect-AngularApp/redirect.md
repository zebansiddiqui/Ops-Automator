# 🌐 Azure Container App: Redirect Default Domain to Custom Subdomain

This document outlines how we implemented a **domain-level redirect** from the Azure default domain to a custom subdomain for an Angular static app hosted on **Azure Container Apps (ACA)**. The solution is **environment-agnostic**, driven by CI/CD-injected environment variables.

---

## 📦 Project Structure

```
XDE-Frontend/
├── Dockerfile
├── nginx.conf.template
├── src/
│   └── environments/
│       ├── environment.ts
│       └── environment.prod.ts
├── angular.json
├── package.json
└── ...
```

---

## 🎯 Goal

Redirect all traffic from:

```
https://<azure-default>.azurecontainerapps.io
```

to:

```
https://<custom-subdomain>.yourdomain.com
```

...using environment variables:

- `DEFAULT_DOMAIN`
- `CUSTOM_DOMAIN`

---

## 🛠️ Dockerfile

```dockerfile
# ---------- Stage 1: Build Angular App ----------
FROM node:20-alpine3.19 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY . .
RUN npm run build -- --configuration production

# ---------- Stage 2: Serve with Nginx ----------
FROM nginx:1.27-alpine

COPY nginx.conf.template /etc/nginx/templates/default.conf.template
RUN apk add --no-cache gettext

COPY --from=build /app/dist/* /usr/share/nginx/html

CMD ["/bin/sh", "-c", "\
  if [ -z \"$DEFAULT_DOMAIN\" ] || [ -z \"$CUSTOM_DOMAIN\" ]; then \
    echo '❌ DEFAULT_DOMAIN or CUSTOM_DOMAIN not set'; exit 1; \
  fi && \
  envsubst '${DEFAULT_DOMAIN} ${CUSTOM_DOMAIN}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && \
  exec nginx -g 'daemon off;'"]
```

---

## 🧩 `nginx.conf.template`

```nginx
server {
    listen 80;
    server_name _;

    if ($host = ${DEFAULT_DOMAIN}) {
        return 301 https://${CUSTOM_DOMAIN}$request_uri;
    }

    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
```

---

## ⚙️ Azure DevOps CI/CD Integration

### ✅ Environment Variables

Ensure the following are defined in your variable groups (`Frontend-dev`, `Frontend-uat`, `Frontend-prod`):

```yaml
DEFAULT_DOMAIN: xde-container-frontend-dev-01.region.azurecontainerapps.io
CUSTOM_DOMAIN: dev.env.project.co.in
```

These are injected into:

- Angular `environment.ts` and `environment.prod.ts`
- Azure Container App runtime via CLI

---

### ✅ Deployment Script Snippet

#### `az containerapp create`

```bash
az containerapp create \
  --name $containerAppName \
  --resource-group $resourceGroup \
  --environment $containerAppEnv \
  --image $(acrLoginServer)/$(imageName):$(Build.BuildId) \
  --cpu 0.25 \
  --memory 0.5Gi \
  --registry-server $(acrLoginServer) \
  --registry-username $USERNAME \
  --registry-password $PASSWORD \
  --ingress external \
  --target-port $(targetPort) \
  --env-vars DEFAULT_DOMAIN=$(DEFAULT_DOMAIN) CUSTOM_DOMAIN=$(CUSTOM_DOMAIN)
```

#### `az containerapp update`

```bash
az containerapp update \
  --name $containerAppName \
  --resource-group $resourceGroup \
  --image $(acrLoginServer)/$(imageName):$(Build.BuildId) \
  --set-env-vars DEFAULT_DOMAIN=$(DEFAULT_DOMAIN) CUSTOM_DOMAIN=$(CUSTOM_DOMAIN)
```

> ⚠️ Use `--env-vars` for `create`, and `--set-env-vars` for `update`.

---

## ✅ Validation

After deployment:

```bash
curl -I https://<azure-default>.azurecontainerapps.io
```

Expected response:

```
HTTP/1.1 301 Moved Permanently
Location: https://<custom-subdomain>.yourdomain.com/...
```

---

## 🧪 Troubleshooting

| Symptom | Cause | Fix |
|--------|-------|-----|
| Build completes in 30s | Nginx config not rendered | Ensure `envsubst` runs at runtime, not build |
| App not reachable | Missing env vars | Validate `DEFAULT_DOMAIN` and `CUSTOM_DOMAIN` are injected |
| `--env-vars` error | Wrong CLI flag | Use `--set-env-vars` for `update` |

---

## 🧾 Summary

- ✅ Angular app is built and served via Nginx
- ✅ Nginx dynamically injects redirect logic using env vars
- ✅ CI/CD pipeline injects domains per environment
- ✅ Redirect is enforced at container level, not DNS

---

Let me know if you'd like a badge, status section, or GitHub Actions version of this setup.
