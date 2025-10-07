# 🟦 Configure GoDaddy Subdomain with Azure Web App

## 🎯 Objective

Map the custom subdomain
`https://dev.sample.abc.ai`
to the Azure Web App
`https://sample1.azurewebsites.net`

---

## 🧩 Prerequisites

* Active Azure Web App (`sample1.azurewebsites.net`)
* Domain `abc.ai` registered in GoDaddy
* Contributor or Owner role on the Web App

---

## ⚙️ Step 1 — Get Azure Web App Information

1. Open **Azure Portal** → navigate to your **Web App**.
2. Copy the **default URL**, e.g. `sample1.azurewebsites.net`.
3. Go to **Custom domains** (left menu) — keep this page open.

---

## 🌐 Step 2 — Add a CNAME Record in GoDaddy

1. Log in to **GoDaddy** → select your domain `abc.ai`.

2. Go to **DNS Management** → **Add Record**.

3. Add the following:

   | Field                 | Value                     |
   | --------------------- | ------------------------- |
   | **Type**              | CNAME                     |
   | **Host / Name**       | dev.sample                |
   | **Points to / Value** | sample1.azurewebsites.net |
   | **TTL**               | Default (1 hour)          |

4. Save the record.

---

## 🧾 Step 3 — Verify DNS Propagation

Use [https://dnschecker.org](https://dnschecker.org)
Search for `dev.sample.abc.ai` → Record Type: **CNAME**
✅ It should resolve to `sample1.azurewebsites.net`.

---

## 🪄 Step 4 — Add the Custom Domain in Azure

1. Go back to the **Azure Web App → Custom domains**.
2. Click **+ Add custom domain**.
3. Enter: `dev.sample.abc.ai` → click **Validate**.
4. If you see:

   ```
   Validation passed. Select Add to finish up.
   ```

   click **Add** to complete the mapping.

📘 *Note*:
You might see a warning —
“No matching TXT record was found…”
This is **optional** and can be ignored, or you can add the TXT record later for ownership verification.

---

## 🔒 Step 5 — Add Free SSL Certificate (HTTPS)

1. Go to **TLS/SSL settings → Private Key Certificates (.pfx)**.
2. Click **Create App Service Managed Certificate**.
3. Choose `dev.sample.abc.ai` → Create.
4. After it appears, go to **Bindings** tab → **Add TLS/SSL Binding**:

   * **Hostname:** `dev.sample.abc.ai`
   * **Certificate:** newly created certificate
   * **TLS/SSL Type:** `SNI SSL`
5. Click **Add Binding**.

---

## 🧪 Step 6 — Test the Setup

After 10–30 minutes (DNS + SSL propagation):

* Visit: `https://dev.sample.abc.ai`
  ✅ It should load your Azure Web App with a valid HTTPS padlock.

---

## 🧰 (Optional) Step 7 — Add Verification TXT Record

To strengthen domain ownership:

1. In GoDaddy → Add **TXT Record**:

   | Field           | Value               |
   | --------------- | ------------------- |
   | **Type**        | TXT                 |
   | **Host / Name** | `_asuid.dev.sample` |
   | **Value**       | (Provided by Azure) |

2. Save the record (purely optional but recommended).

---

## ✅ Summary

| Step | Action                                                      | Platform     |
| ---- | ----------------------------------------------------------- | ------------ |
| 1    | Get Azure Web App default URL                               | Azure Portal |
| 2    | Add CNAME record (`dev.sample → sample1.azurewebsites.net`) | GoDaddy      |
| 3    | Validate domain                                             | Azure Portal |
| 4    | Add custom domain                                           | Azure Portal |
| 5    | Create free SSL certificate                                 | Azure Portal |
| 6    | Verify access                                               | Browser      |
| 7    | (Optional) Add TXT record for ownership                     | GoDaddy      |

---

### 🏁 Result

Your Azure Web App is now accessible via the secure subdomain:

```
https://dev.sample.abc.ai
```
