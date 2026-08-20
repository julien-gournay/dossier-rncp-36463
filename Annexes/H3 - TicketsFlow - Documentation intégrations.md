# Intégrations API & Portail SSO — TicketsFlow Backoffice

Documentation technique des services externes intégrés au backoffice
(Pretix, Stripe, SumUp) et de l'authentification déléguée au portail
**ticketsflow-sso**.

## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Authentification — portail ticketsflow-sso](#2-authentification--portail-ticketsflow-sso)
3. [Pretix — billetterie](#3-pretix--billetterie)
4. [Stripe — paiements](#4-stripe--paiements)
5. [SumUp — paiements terrain](#5-sumup--paiements-terrain)
6. [Variables d'environnement](#6-variables-denvironnement)
7. [Dépannage](#7-dépannage)

---

## 1. Vue d'ensemble

```
                         ┌───────────────────────┐
   Navigateur  ───────▶  │  ticketsflow-sso        │  (portail, /Google + bénévole)
                         │  → cookie tf_sso (JWT)  │
                         └──────────┬──────────────┘
                                    │ cookie partagé (path=/)
                                    ▼
                         ┌───────────────────────┐
                         │  ticketsflow-backoffice  │
                         │  includes/auth_helper   │──▶ MySQL `ticketsflow`
                         │  assets/php/sso_client   │      (events, orders, users…)
                         └───┬──────────┬──────────┘
                             │          │
                 services/PretixService │ services/StripeService
                             │          │
                             ▼          ▼
                        API Pretix   API Stripe (SDK)
                                    services/SumupService
                                          │
                                          ▼
                                     API SumUp
```

Aucun de ces services externes (Pretix/Stripe/SumUp) n'est appelé par le
portail SSO, celui-ci ne gère que l'identité et les autorisations. Chaque
intégration métier reste isolée dans `services/*.php` et n'est consommée
que côté backoffice, via un contrôleur (`DashboardController`) ou
directement depuis une vue.

| Intégration | Fichier | Authentification | Dépendance |
|---|---|---|---|
| SSO (auth) | [`assets/php/sso_client.php`](../assets/php/sso_client.php) | Cookie JWT signé HMAC (`SSO_SECRET`) | Aucune (PHP pur) |
| Pretix | [`services/PretixService.php`](../services/PretixService.php) | Token statique (`PRETIX_TOKEN`) | `guzzlehttp/guzzle` |
| Stripe | [`services/StripeService.php`](../services/StripeService.php) | Clé secrète (`STRIPE_SECRET_KEY`) | `stripe/stripe-php` (SDK officiel) |
| SumUp | [`services/SumupService.php`](../services/SumupService.php) | Bearer token statique (`SUMUP_API_KEY`) | `guzzlehttp/guzzle` |

---

## 2. Authentification — portail ticketsflow-sso

### 2.1 Principe

Le backoffice ne gère plus lui-même la connexion Google OAuth : c'est le
portail **ticketsflow-sso** (`c:\wamp64\www\ticketsflow-sso`, tourne à
`http://localhost/ticketsflow-sso`) qui authentifie l'utilisateur (Google
Workspace *ou* compte bénévole identifiant/mot de passe) et pose un cookie
de session partagé sur le domaine.

1. Une page protégée du backoffice appelle `requireAuth()`.
2. Si le cookie `tf_sso` est absent/invalide/expiré, redirection vers
   `ticketsflow-sso/index.php?return=<url d'origine>`.
3. Une fois connecté sur le portail, l'utilisateur est ramené sur
   `return`, avec le cookie `tf_sso` posé (`path=/`, `HttpOnly`,
   `SameSite=Lax`, `Secure` si HTTPS).
4. Le backoffice vérifie ce cookie **localement**, sans requête réseau vers
   le portail (JWT HS256 signé avec le secret partagé `SSO_SECRET`).

Documentation complète du portail (installation, admin, sécurité) :
`c:\wamp64\www\ticketsflow-sso\README.md`.

### 2.2 Fichiers côté backoffice

| Fichier | Rôle |
|---|---|
| [`assets/php/sso_client.php`](../assets/php/sso_client.php) | Copie verbatim du client SSO (voir le portail, `client/sso_client.php`) — **ne pas modifier**, juste re-copier depuis le portail en cas de mise à jour. |
| [`includes/env_helper.php`](../includes/env_helper.php) | Définit `env()` (utilisé par `sso_client.php`) — nécessaire car `Dotenv::createImmutable()` ne peuple que `$_ENV`, pas `getenv()` (voir [§7](#7-dépannage)). |
| [`includes/auth_helper.php`](../includes/auth_helper.php) | Point d'intégration : `requireAuth()`, `requireAdmin()`, `requireFinance()`, synchronisation `$_SESSION`/table `users`. |
| [`auth/logout.php`](../auth/logout.php) | Déconnexion : nettoie la session locale puis redirige vers `sso_logout_url()` (efface le cookie partagé). |

### 2.3 Jeton JWT — claims utilisés

Émis par le portail, vérifié par `sso_verify_token()` (signature HMAC-SHA256
+ expiration) :

```jsonc
{
  "sub": "6",                     // id utilisateur côté portail (stable)
  "auth_type": "google",          // "google" | "local" (bénévole)
  "email": "jgournay@ticketsflow.fr", // null pour un compte bénévole
  "username": null,               // renseigné pour un compte bénévole
  "name": "Julien GOURNAY",
  "hd": "ticketsflow.fr",
  "services": {                   // droits calculés à la connexion
    "backoffice": ["default", "admin", "finance"],
    "planner": ["default"]
  },
  "expires_at": null,             // date d'expiration de compte (admin SSO)
  "exp": 1755712345                // expiration du jeton (SSO_TOKEN_TTL, 12h par défaut)
}
```

### 2.4 Pages du service `backoffice` déclarées côté portail

Le service `backoffice` et ses pages sont déclarés dans la base
`ticketsflow_sso` (table `services` / `service_pages`), gérables depuis
`http://localhost/ticketsflow-sso/admin/service.php` :

| Page SSO | Usage backoffice | Défaut Google | Défaut bénévole |
|---|---|---|---|
| `default` | Accès général au backoffice | ✅ autorisé | ✅ autorisé |
| `admin` | Section *Administration* (utilisateurs, journaux) | ❌ refusé | ❌ refusé |
| `finance` | Section *Finance* (Stripe, SumUp) | ❌ refusé | ❌ refusé |

`admin`/`finance` sont refusées par défaut pour tout le monde ; l'accès se
donne individuellement depuis la fiche utilisateur du portail (« Gérer » →
tableau Outil/Page → Autoriser). Un changement ne prend effet qu'à la
prochaine connexion (durée de vie du jeton, `SSO_TOKEN_TTL`).

### 2.5 API dans le code (`includes/auth_helper.php`)

```php
require_once __DIR__ . '/includes/auth_helper.php';

requireAuth();    // page "default" — connexion + accès général requis
requireAdmin();   // + page "admin"
requireFinance(); // + page "admin" OU "finance"

isAdmin();         // bool, lit $_SESSION['user_role'] === 'admin'
isFinance();       // bool, 'admin' ou 'finance'

logAdminAction($_SESSION['user_id'], 'action', 'entity_type', $entityId, 'détails');
```

`requireAuth()` (et donc `requireAdmin()`/`requireFinance()`, qui l'appellent
en premier) fait aussi la synchronisation avec la table locale `users`
(`syncSessionFromSsoUser()`) : elle upsert une ligne par `sub` JWT (stocké
dans la colonne `google_id`, réutilisée comme identifiant externe générique, le backoffice ne parle plus directement à Google), en dérive le rôle
(`admin`/`finance`/`user`) et peuple `$_SESSION['user_id'|'user_name'|
'user_email'|'user_role']` pour compatibilité avec les vues existantes
(`header.php`, `dashboard.php`) et pour `admin_logs.user_id`.

### 2.6 Bascule de développement — `SSO_ENABLED`

```ini
# .env
SSO_ENABLED=false   # dev : bypass le portail, utilisateur factice tous droits
SSO_ENABLED=true    # prod : passe réellement par ticketsflow-sso
```

À `false`, `requireAuth()` simule
`['sub'=>'dev-local','email'=>'dev@localhost','services'=>['backoffice'=>['default','admin','finance']]]`
sans jamais contacter le portail — pratique pour développer en local sans
dépendre d'`ticketsflow-sso`, mais **à ne jamais laisser à `false` en
production**.

### 2.7 Gestion des accès — page `/views/admin/users.php`

Depuis l'intégration SSO, cette page n'édite plus aucun rôle localement :
elle affiche en lecture seule les comptes vus par le backoffice (reflet
local synchronisé à chaque connexion) et pointe vers l'admin du portail
(`SSO_PORTAL_URL/admin/`) pour toute action (créer un bénévole, activer/
désactiver un compte, gérer les pages `admin`/`finance`).

---

## 3. Pretix — billetterie

Classe : [`services/PretixService.php`](../services/PretixService.php).
API REST Pretix (`PRETIX_API_URL`, ex.
`https://tickets.ticketsflow.fr/api/v1`), authentifiée par token statique
(`Authorization: Token <PRETIX_TOKEN>`) via un client Guzzle partagé.

### 3.1 Méthodes

| Méthode | Description | Utilisée dans |
|---|---|---|
| `getEventShopStatuses(array $slugs): array` | Statut live/pré-vente (1 appel paginé pour tous les slugs demandés) → `[slug => ['open'=>bool,'presale_start'=>...] \| null]` | [`views/events/list.php`](../views/events/list.php) |
| `getEvents()` | Liste brute des événements de l'organisateur (`/organizers/{org}/events/`) | — |
| `getOrders($eventSlug, $page = 1)` | Commandes paginées d'un événement (`/organizers/{org}/events/{slug}/orders/`) | interne à `syncOrders*()` |
| `syncOrders($eventId, $eventSlug): int` | Synchronise (upsert) les commandes Pretix d'un événement dans la table `orders` (`event_id`) | [`views/orders/list.php`](../views/orders/list.php) |
| `syncOrdersByMainEvent(int $mainEventId, string $codeProj): int` | Idem, mais rattaché à un *main event* (`main_event_id`) | [`views/orders/list.php`](../views/orders/list.php) |

### 3.2 Mapping des statuts

Pretix (`order.status`, un caractère) → colonne locale `orders.status` :

| Pretix | Local |
|---|---|
| `n` (en attente) | `pending` |
| `p` (payée) | `paid` |
| `e` / `c` (expirée / annulée) | `cancelled` |
| `r` (remboursée) | `refunded` |
| autre | `pending` (repli) |

### 3.3 Configuration

```ini
PRETIX_API_URL=https://tickets.ticketsflow.fr/api/v1
PRETIX_ORGANIZER=tf
PRETIX_TOKEN=<token API Pretix>
```

`DISABLE_SSL_VERIFY=true` désactive la vérification TLS du client Guzzle
(WAMP/Windows en dev uniquement — **jamais en production**).

---

## 4. Stripe — paiements

Classe : [`services/StripeService.php`](../services/StripeService.php),
au-dessus du SDK officiel `stripe/stripe-php`. Consommée exclusivement via
[`controllers/DashboardController.php`](../controllers/DashboardController.php),
lui-même utilisé par le dashboard et
[`views/admin/stripe.php`](../views/admin/stripe.php) (protégée par
`requireFinance()`).

### 4.1 Méthodes

| `StripeService` | `DashboardController` | Description |
|---|---|---|
| `getRevenue($period)` | — (appelée par `getDetailedStats`) | CA/frais/net sur une période (`all`\|`today`\|`week`\|`month`\|`year`), via `\Stripe\BalanceTransaction::all()` |
| `getDetailedStats()` | `getStripeStats()` | `getRevenue()` sur les 5 périodes en une fois |
| `getRecentPayments($limit)` | `getStripeRecentPayments($limit)` | Derniers `\Stripe\Charge` (montant, client, statut…) |
| `getMonthlyRevenue()` | `getStripeMonthlyRevenue()` | CA mensuel sur 12 mois glissants |
| `getGlobalStats()` | `getStripeGlobalStats()` | Compteurs globaux : paiements réussis/échoués, montant total, remboursé, net |

Tous les montants sont renvoyés en euros (conversion `/100` depuis les
centimes Stripe). Chaque méthode retourne `['success' => bool, ...]` ou
`['success' => false, 'error' => ...]` en cas d'`\Stripe\Exception\ApiErrorException`.

### 4.2 Configuration

```ini
STRIPE_SECRET_KEY=sk_live_... # ou sk_test_... en dev
STRIPE_PUBLIC_KEY=pk_live_... # non utilisée côté backoffice (pas de Stripe.js ici)
```

⚠️ Les clés `sk_live_*` donnent accès aux vraies transactions — traiter
`.env` comme un secret (déjà dans `.gitignore`).

---

## 5. SumUp — paiements terrain

Classe : [`services/SumupService.php`](../services/SumupService.php).
Utilisée par [`views/admin/sumup.php`](../views/admin/sumup.php) (protégée
par `requireFinance()`).

### 5.1 Méthode

| Méthode | Description |
|---|---|
| `getTransactions($limit = 20)` | `GET https://api.sumup.com/v0.1/me/transactions/history?limit=&order=descending`, normalise chaque transaction (`id`, `amount`, `currency`, `status`, `payment_type`, `product`, `created`) |

Renvoie `['success' => false, 'error' => "Clé API SumUp non configurée…"]`
si `SUMUP_API_KEY` est vide — pas d'appel réseau dans ce cas.

### 5.2 Configuration

```ini
SUMUP_API_KEY=<clé API générée depuis le dashboard développeur SumUp>
```

---

## 6. Variables d'environnement

Référence complète — voir [`.env.example`](../.env.example) (à copier en
`.env`, jamais commité).

| Variable | Utilisée par | Exemple |
|---|---|---|
| `DB_HOST` / `DB_NAME` / `DB_USER` / `DB_PASS` | `config/Database.php` | `localhost` / `ticketsflow` / `root` / *(vide)* |
| `APP_TIMEZONE` | `includes/auth_helper.php` | `Europe/Paris` — **doit matcher celui du portail SSO** |
| `SSO_SECRET` | `assets/php/sso_client.php` | *(même valeur que `ticketsflow-sso/.env`)* |
| `SSO_PORTAL_URL` | idem | `http://localhost/ticketsflow-sso` |
| `SSO_ENABLED` | `includes/auth_helper.php` | `false` en dev, `true` en prod |
| `PRETIX_API_URL` / `PRETIX_ORGANIZER` / `PRETIX_TOKEN` | `services/PretixService.php` | voir [§3.3](#33-configuration) |
| `STRIPE_SECRET_KEY` / `STRIPE_PUBLIC_KEY` | `services/StripeService.php` | voir [§4.2](#42-configuration) |
| `SUMUP_API_KEY` | `services/SumupService.php` | voir [§5.2](#52-configuration) |
| `APP_URL` | `auth/logout.php` (retour par défaut) | `http://localhost/ticketsflow-backoffice` |
| `ADMIN_EMAIL` | non utilisée par le code actuel (héritage) | — |
| `DISABLE_SSL_VERIFY` | `PretixService`, `SumupService` | `false` (dev WAMP uniquement si besoin) |

---

## 7. Dépannage

### `getenv('SSO_...')` renvoie toujours `false`

`vlucas/phpdotenv` v5 (`Dotenv::createImmutable()`) ne peuple par défaut
que `$_ENV`/`$_SERVER`, **pas** les variables d'environnement réelles
(`putenv`). Or `sso_client.php` (générique, partagé entre tous les outils)
lit ses variables via une fonction `env()` si elle existe, sinon
`getenv()`. Sans `env()` définie, `SSO_SECRET`/`SSO_PORTAL_URL` sont donc
invisibles pour lui. Corrigé par [`includes/env_helper.php`](../includes/env_helper.php),
chargé avant tout `require` de `sso_client.php`.

### Redirection vers `/ticketsflow-backend/...` (404)

Ancien nom du dossier projet ; plusieurs chemins étaient codés en dur. Tous
les chemins en dur du code PHP ont été alignés sur `/ticketsflow-backoffice`
(`includes/header.php` → `$base`, `index.php`, etc.). Si un 404 vers
`/ticketsflow-backend/` réapparaît, chercher une chaîne codée en dur restante
(`grep -rn "ticketsflow-backend" --include=*.php .`).

### `strftime()` deprecated

Fonction PHP dépréciée depuis 8.1. Remplacée dans
[`views/dashboard.php`](../views/dashboard.php) par un formatage manuel
(tableaux jours/mois en français), sans dépendance à la locale système.

### Un utilisateur ne peut pas accéder à Administration/Finance

Les rôles ne sont plus dans la table locale `users.role` (purement
informative désormais) mais décidés par le portail SSO. Vérifier/accorder
depuis `http://localhost/ticketsflow-sso/admin/` → fiche utilisateur →
« Gérer » → pages `backoffice/admin` et `backoffice/finance`. Le nouvel
accès ne prend effet qu'à la prochaine connexion (jeton en cours non
invalidé avant `SSO_TOKEN_TTL`).

### `vendor/autoload.php` introuvable

Le backoffice a des dépendances Composer (`vlucas/phpdotenv`,
`guzzlehttp/guzzle`, `stripe/stripe-php`) — contrairement au portail SSO
qui n'en a aucune. Lancer `composer install` à la racine du projet.
