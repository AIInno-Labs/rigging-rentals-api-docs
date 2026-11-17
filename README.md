# Rigging Rentals API docs

API documentation for the Rigging Rentals platform (Spring Boot backend, React frontend), hosted on GitHub Pages.

| Page | What it is |
|---|---|
| `index.html` | Swagger UI: browse and try the endpoints |
| `redoc.html` | Redoc: a clean, readable reference |
| `openapi.yaml` | The OpenAPI 3.0.3 contract (the source of truth) |

## Publish on GitHub Pages (one-time setup)

1. Create a new repository on GitHub, e.g. `rigging-rentals-api-docs`.
2. Push this folder to it:
   ```bash
   cd rigging-rentals-api-docs
   git init -b main
   git add .
   git commit -m "API docs: OpenAPI spec + Swagger UI + Redoc"
   git remote add origin https://github.com/<your-account>/rigging-rentals-api-docs.git
   git push -u origin main
   ```
3. On GitHub, go to **Settings → Pages → Build and deployment → Source** and choose **GitHub Actions**.
4. Open the **Actions** tab. The workflow *Validate & publish API docs* validates the spec and deploys the site (about 1 minute).
5. The site is live at `https://<your-account>.github.io/rigging-rentals-api-docs/`.

## Updating the spec

Edit `openapi.yaml` and push to `main`. The workflow:
- validates the spec, and does not deploy if the spec is invalid;
- redeploys the site automatically.

Pull requests are validated but not deployed, so spec changes can be reviewed first.

## Privacy

- On a **public** repository the Pages site is public. That is fine for a client review if the spec has no secrets (it has none: only example data and placeholder hosts).
- To restrict access, use a private repository on a GitHub Enterprise Cloud plan and set Pages visibility to private. Otherwise, use a private repo and share the YAML through Postman or SwaggerHub instead.

## Local preview

```bash
python3 -m http.server 8000
# open http://localhost:8000
```
(Opening `index.html` straight from disk will not load the YAML. Browsers block `file://` fetches, so use a local server.)

## Use from the React app

Generate a typed API client from the published spec:
```bash
npx openapi-typescript-codegen --input https://<your-account>.github.io/rigging-rentals-api-docs/openapi.yaml --output src/api --client axios
```
