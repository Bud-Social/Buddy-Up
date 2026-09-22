# BuddyUp — Domain, Email & SEO Setup Checklist

Everything marked **[dashboard]** is click-work only you can do (Vercel / registrar /
Zoho / Resend dashboards). Everything else is already committed in this repo.

Canonical decisions used everywhere below and in the code:

- Canonical marketing host: `https://buddyup.com` (bare domain; `www` redirects to it)
- Logged-in app (future split): `app.buddyup.com`
- Django API (future): `api.buddyup.com`
- Mailboxes: Zoho Mail Free on `buddyup.com`, forwarding via Forward Email on `buddyup.co.ke`
- Transactional mail: Resend, sending from `mail.buddyup.com`

---

## 1. Vercel DNS — `buddyup.com` **[dashboard]**

Vercel Dashboard → team → Domains → `buddyup.com` → DNS Records.

| Type | Name | Value | Purpose |
|---|---|---|---|
| A | `@` | `76.76.21.21` | Vercel apex (already done) |
| CNAME | `www` | `cname.vercel-dns.com` | Canonical marketing host |
| CNAME | `app` | `cname.vercel-dns.com` | Logged-in app host (already done) |
| CNAME | `api` | `<your-app>.up.railway.app` | Get the exact target from Railway → Service → Settings → Networking → Custom Domain |
| CNAME | `help` / `status` | `cname.vercel-dns.com` | Placeholders; they 404 until assigned to a project |

⚠️ Do **not** add a `mail` CNAME to Vercel — `mail.` belongs to Resend (section 3).

Then Project → Settings → Domains: add `buddyup.com`, `www.buddyup.com`
(set `www` → redirect to apex), and `app.buddyup.com` on the app project.

## 2. Vercel DNS — `buddyup.co.ke` **[dashboard]**

| Type | Name | Value | Purpose |
|---|---|---|---|
| A | `@` | `76.76.21.21` | Kenyan visitors land here, app redirects to .com |
| MX | `@` | `10 mx1.forwardemail.net` | report@/help@/contact@ forwarding |
| MX | `@` | `20 mx2.forwardemail.net` | |
| TXT | `@` | `v=spf1 include:forwardemail.net ~all` | SPF |

Plus the domain-verification TXT that forwardemail.net shows you (free plan).

## 3. Mailboxes

### 3a. Zoho Mail Free — real inbox + aliases on `buddyup.com` **[dashboard]**

1. zoho.com/mail → **Forever Free** plan → add domain `buddyup.com`.
2. Add the `zoho-verification=zb...` TXT record it shows, in Vercel DNS.
3. Create user `support@buddyup.com` (free: up to 5 users).
4. Admin → Users → support → **Aliases**: `info@`, `privacy@`, `legal@`, `dpo@`, `security@`.
   Admin → Groups: `security@` if it needs multiple recipients.
5. Add Zoho's DNS records (it shows exact values):
   - `MX @ 10 mx.zoho.com` / `20 mx2.zoho.com` / `50 mx3.zoho.com`
   - `TXT @ v=spf1 include:zohomail.com include:amazonses.com ~all`
   - `CNAME <zoho-selector>._domainkey <value>` (enable DKIM in Zoho first)
   - `TXT _dmarc v=DMARC1; p=quarantine; rua=mailto:support@buddyup.com`

### 3b. Forward Email — `report@` / `help@` / `contact@` on `buddyup.co.ke` **[dashboard]**

forwardemail.net → add domain `buddyup.co.ke` → aliases:
`report@` → support inbox, `help@` → support, `contact@` → info.
DNS records in section 2.

### 3c. Resend — transactional `noreply@` (Vercel Marketplace) **[dashboard]**

1. Vercel Dashboard → Marketplace/Storage → **Resend** → Install → creates `RESEND_API_KEY`.
2. Resend → Domains → add `mail.buddyup.com` → add its 3 records to Vercel DNS on `buddyup.com`:
   - `TXT resend._domainkey.mail <DKIM value>`
   - `TXT mail v=spf1 include:amazonses.com ~all`
   - `MX send.mail 10 feedback-smtp.<region>.amazonses.com`
3. Railway env vars:

   ```
   DEFAULT_FROM_EMAIL=BuddyUp <noreply@mail.buddyup.com>
   RESEND_API_KEY=<from Vercel/Resend>
   ```

   (Wire Django's email backend to Resend SMTP/API when you implement transactional email.)

## 4. App wiring

- **Railway env**: `ALLOWED_HOSTS=api.buddyup.com`,
  `CSRF_TRUSTED_ORIGINS=https://app.buddyup.com,https://buddyup.com`
- **Frontend env (Vercel)**: `VITE_API_URL=https://api.buddyup.com` → redeploy
- **Google Cloud Console → Credentials → OAuth client → Authorized JavaScript origins**:
  add `https://app.buddyup.com` (missing this silently breaks Google sign-in)

## 5. Search engine visibility (already in the repo)

Done in code (committed):

- `frontend/public/robots.txt` — only marketing pages crawlable (incl. AI crawlers); sitemap → `https://buddyup.com/sitemap.xml`
- `frontend/public/sitemap.xml` — landing + about + help + 7 legal pages only
- `frontend/public/llms.txt` — AI-discovery file
- `frontend/index.html` — canonical, Open Graph, Twitter card, JSON-LD (Organization + WebSite)
- `vercel.json` — `X-Robots-Tag: noindex, nofollow` on every route except the marketing pages

**[dashboard]** After deploying:

1. Google Search Console → add property `buddyup.com` → verify via the DNS TXT it gives you (paste into Vercel DNS) → Sitemaps → submit `https://buddyup.com/sitemap.xml` → URL Inspection → request indexing of `/`.
2. Bing Webmaster Tools → "Import from Google Search Console".

## 6. Verify everything

```bash
# Crawl policy
curl -s https://buddyup.com/robots.txt
# App route must return noindex header; landing must NOT:
curl -sI https://buddyup.com/feed | grep -i x-robots-tag      # -> noindex, nofollow
curl -sI https://buddyup.com/ | grep -i x-robots-tag          # -> (empty)
curl -sI https://buddyup.com/sitemap.xml | head -1            # -> 200

# Mail authentication (send test from support@ to a Gmail, then check):
# Gmail → ⋮ → Show original → expect SPF: PASS, DKIM: PASS, DMARC: PASS
```

Expected after 1–2 weeks in GSC Coverage: landing/marketing pages indexed;
every app route absent.

## 7. Future (not in this checklist)

- Split landing vs app into two Vercel projects on `buddyup.com` / `app.buddyup.com`
- Prerender `/` to static HTML (AI crawlers don't execute JavaScript)
- 1200×630 `og-image.png` (currently using `/icons/icon-512.png`)
