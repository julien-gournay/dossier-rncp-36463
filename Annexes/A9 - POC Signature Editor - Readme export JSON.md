# Export / Import JSON — Documentation technique

## Vue d'ensemble

Le système de signature propose un mécanisme complet d'export et d'import au format JSON permettant de sauvegarder, transférer et restaurer une configuration de signature entre différentes sessions ou logiciels. Ce format est la représentation **sérialisée et portable** de l'état complet d'une signature.

---

## 1. Comment fonctionne l'export JSON

### Déclenchement

L'export est déclenché depuis deux points d'entrée :

| Contexte | Méthode |
|---|---|
| `SignatureCreatorPanel` | Bouton "Télécharger en JSON" → `saveJSONMethod(signatureName, description)` |
| Modal `SelectSignature` | Bouton de téléchargement rapide → `handleDirectJsonDownload()` |

### Processus (`useSignatureExport.ts` — `saveJSONMethod`)

1. `saveJSONMethod` reçoit optionnellement `signatureName` et `description` (trimés avant usage).
2. Construction d'un objet `payload` en mémoire à partir des `Ref` Vue actifs.
3. Inclusion **conditionnelle** des sections selon l'état de l'interface :
   - `description` → uniquement si la valeur n'est pas vide après trim
   - `nameSignature` → uniquement si l'onglet actif est `"text"`
   - `nameSignature.initials` → uniquement si `showAbbreviatedName` est actif
   - `topContent` → uniquement si le contenu complémentaire haut est activé
   - `bottomContent` → uniquement si le contenu complémentaire bas est activé
   - `signature.draw` → uniquement si l'onglet est `"draw"`
   - `signature.importedImage` → uniquement si l'onglet est `"import"`
4. Sérialisation via `JSON.stringify(payload, null, 2)` (formaté avec indentation).
5. Création d'un `Blob` de type `application/json;charset=utf-8`.
6. Téléchargement déclenché côté client via un lien `<a>` temporaire.
7. Révocation immédiate de l'URL objet (`URL.revokeObjectURL`) pour libérer la mémoire.

Le nom du fichier généré suit le format : `signature-YYYY-MM-DD.json`

---

## 2. Structure du fichier JSON

### Squelette complet

```json
{
  "version": 1,
  "exportedAt": "2026-05-19T10:30:00.000Z",
  "signatureTitle": "Ma signature",
  "description": "Signature professionnelle direction",
  "selectedTab": "text | draw | import",
  "exportWithBackground": true,

  "stamp": {
    "imageDataUrl": "data:image/png;base64,iVBORw0KGgo...",
    "fileName": "tampon.png",
    "position": "left | right | center",
    "scale": 1.0,
    "opacity": 0.8
  },

  "nameSignature": {
    "firstName": "Jean",
    "lastName": "Dupont",
    "abbreviated": false,
    "initials": "J.D.",
    "style": {
      "font": "Georgia",
      "color": "var(--semantic-red-content-accent)"
    }
  },

  "topContent": {
    "enabled": true,
    "value": "Directeur Général",
    "style": {
      "font": "Arial",
      "color": "#1f2937",
      "size": 14,
      "alignment": "left",
      "bold": false,
      "italic": false,
      "underline": false
    }
  },

  "bottomContent": {
    "enabled": true,
    "value": "ACME Corp. — Paris",
    "style": {
      "font": "Arial",
      "color": "#1f2937",
      "size": 14,
      "alignment": "left",
      "bold": false,
      "italic": false,
      "underline": false
    }
  },

  "signature": {
    "source": "draw | import | none",

    "draw": {
      "width": 800,
      "height": 200,
      "strokes": [
        {
          "color": "#0f172a",
          "size": 3,
          "points": [
            { "x": 120, "y": 80 },
            { "x": 125, "y": 85 }
          ]
        }
      ]
    },

    "importedImage": {
      "fileName": "ma-signature.png",
      "imageDataUrl": "data:image/png;base64,iVBORw0KGgo..."
    }
  }
  "stamp": {
    "imageDataUrl": "data:image/jpeg;base64,/9j/4AAQSkZJ..."
    "fileName": "r50.jpg",
    "position": "center",
    "scale": 1,
    "opacity": 0.2
  },
  "description": "test"
}
```

### Détail des champs

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `version` | `number` | Oui | Version du schéma (actuellement `1`) |
| `exportedAt` | `string` (ISO 8601) | Oui | Horodatage de l'export |
| `signatureTitle` | `string` | Oui | Titre/libellé de la signature |
| `description` | `string` | Non | Description libre de la signature |
| `selectedTab` | `"text" \| "draw" \| "import"` | Oui | Mode actif au moment de l'export |
| `exportWithBackground` | `boolean` | Oui | Inclure le fond blanc à l'export image |
| `stamp` | objet | Non | Configuration du tampon superposé |
| `stamp.imageDataUrl` | `string` (base64) | Oui (si stamp) | Image du tampon encodée en base64 |
| `stamp.fileName` | `string` | Oui (si stamp) | Nom du fichier source du tampon |
| `stamp.position` | `"left" \| "right" \| "center"` | Oui (si stamp) | Position du tampon dans la signature |
| `stamp.scale` | `number` (0.5–2.0) | Oui (si stamp) | Facteur d'échelle du tampon |
| `stamp.opacity` | `number` (0.1–1.0) | Non | Opacité, utilisée en position `"center"` |
| `nameSignature` | objet | Conditionnel | Présent uniquement si `selectedTab === "text"` |
| `nameSignature.initials` | `string` | Conditionnel | Présent uniquement si `abbreviated === true` |
| `topContent` | objet | Conditionnel | Présent uniquement si le bloc haut est activé |
| `bottomContent` | objet | Conditionnel | Présent uniquement si le bloc bas est activé |
| `signature.source` | `"draw" \| "import" \| "none"` | Oui | Origine des données de signature visuelle |
| `signature.draw` | objet | Conditionnel | Présent uniquement si `source === "draw"` |
| `signature.importedImage` | objet | Conditionnel | Présent uniquement si `source === "import"` |

### Types disponibles

```typescript
type SignatureTab     = "text" | "draw" | "import"
type TextAlignment    = "left" | "center" | "right"
type FontChoice       = "Arial" | "Georgia" | "Courier New" | "Times New Roman" | "Ms Madi"
```

---

## 3. Comment fonctionne l'import JSON

### Déclenchement

L'import est possible depuis deux contextes :

| Contexte | Méthode |
|---|---|
| `SignatureCreatorPanel` | Input `<input type="file">` → `handleJsonImportFile()` |
| Modal `SelectSignature` | Chargement d'une carte sauvegardée → `loadSignatureFromJson()` |

### Processus (`useSignatureJsonImport.ts`)

1. L'utilisateur sélectionne un fichier `.json` via un `<input type="file">`.
2. Vérification préalable du type de fichier : `file.type === "application/json"` ou extension `.json`. Un toast d'erreur est affiché si le format est incorrect.
3. `FileReader.readAsText()` lit le fichier de façon **asynchrone**.
4. Le contenu est parsé via `JSON.parse()` dans un bloc `try/catch`.
   - En cas d'échec de parsing : toast d'erreur "Le fichier n'est pas un JSON valide.", aucun état modifié.
5. `validateSignatureJson(payload)` vérifie la présence d'au moins une signature valide (texte, dessin ou image importée). Un toast d'erreur est affiché si la validation échoue.
6. `loadSignatureFromJson(payload)` hydrate les `Ref` Vue un par un.
7. `drawingCanvasKey` est incrémenté pour forcer le re-montage du canvas de dessin.
8. La prévisualisation est re-rendue immédiatement via `renderPreview()`.
9. Un toast de succès confirme l'import avec le nom du fichier.
10. L'input est réinitialisé (`input.value = ""`) pour permettre un re-import du même fichier.

### Validation à l'import

**Validation structurelle** (`validateSignatureJson`) :

Un payload est considéré invalide si aucune des conditions suivantes n'est remplie :
- `nameSignature.firstName` ou `nameSignature.lastName` non vide
- `signature.source === "draw"` avec au moins un stroke dans `signature.draw.strokes`
- `signature.source === "import"` avec `signature.importedImage.imageDataUrl` non vide

**Validation des valeurs** par des utilitaires dédiés :

| Utilitaire | Rôle |
|---|---|
| `asString(val, default)` | Garantit une chaîne, retourne le défaut si absent/invalide |
| `asNumber(val, default)` | Garantit un nombre, retourne le défaut si absent/invalide |
| `asBoolean(val, default)` | Garantit un booléen |
| `toFontChoice(val)` | Valide que la police est dans la liste autorisée |
| `isAlignment(val)` | Valide que l'alignement est `left`, `center` ou `right` |

Si un champ est absent ou invalide dans le JSON importé, la valeur par défaut est appliquée silencieusement — **aucun plantage n'est possible**.

### `useJsonImportHandler` — fonction exportée séparément

`useJsonImportHandler(onSuccess)` est une factory exportée indépendamment de `useSignatureJsonImport`. Elle permet à tout composant (ex. `SelectSignature`) de brancher la logique de lecture de fichier sur un callback personnalisé, sans instancier l'ensemble du composable d'import.

---

## 4. Agrégation et consolidation (sauvegarde locale)

### Stockage dans le navigateur

En parallèle de l'export fichier, les signatures peuvent être **consolidées localement** dans le `localStorage` du navigateur. Ce mécanisme est entièrement géré par le composable `useSignatureStorage.ts`.

| Clé `localStorage` | Contenu |
|---|---|
| `signature_saved_cards` | Tableau JSON de toutes les cartes sauvegardées |
| `signature_next_id` | Compteur auto-incrémenté pour les identifiants de cartes |
| `signature_default_id` | Identifiant de la carte désignée comme signature par défaut |

### Structure d'une carte sauvegardée

```json
{
  "id": 3,
  "name": "Jean Dupont — Directeur",
  "previewDataUrl": "data:image/svg+xml;charset=utf-8,...",
  "payload": { /* SignatureConfigJson complet */ }
}
```

> **Note** : L'aperçu est généré en SVG (via `buildSignatureCardPreviewDataUrl` dans `useSignatureStorage.ts`), non en PNG.

### Cycle de vie

```
Création (useSignatureStorage.addSignatureCard)
  → Construction du payload (même structure que l'export fichier)
  → Génération d'un aperçu SVG (data URL) pour la carte via buildSignatureCardPreviewDataUrl
  → Ajout en tête du tableau savedSignatureCards
  → Persistance immédiate dans localStorage (dans addSignatureCard ET via watcher Vue)

Chargement (loadSignatureFromJson)
  → Hydration des Ref Vue depuis le payload de la carte
  → Re-rendu immédiat de la prévisualisation

Suppression
  → Retrait du tableau → le watcher propage la mise à jour dans localStorage
```

### Limites de la consolidation locale

- Le `localStorage` est limité à **~5 Mo** par origine (domaine+protocole).
- Les signatures avec des images importées en base64 peuvent être volumineuses.
- En navigation privée ou si le quota est dépassé, la sauvegarde échoue silencieusement (bloc `try/catch`).
- Les données sont **isolées par navigateur et par poste** — non synchronisées entre postes.

---

## 5. Conformité RGPD

### Nature des données traitées

Le fichier JSON peut contenir des **données à caractère personnel** au sens du RGPD (Règlement UE 2016/679) :

| Champ | Qualification RGPD |
|---|---|
| `nameSignature.firstName` | Donnée personnelle (prénom) |
| `nameSignature.lastName` | Donnée personnelle (nom de famille) |
| `signature.importedImage.imageDataUrl` | Donnée biométrique potentielle (image de signature manuscrite) — **catégorie sensible** |
| `stamp.imageDataUrl` | Potentiellement nominatif si le tampon contient un nom ou une image personnelle |
| `exportedAt` | Horodatage non nominatif |
| `signatureTitle` | Potentiellement nominatif selon la valeur saisie |
| `description` | Potentiellement nominatif selon la valeur saisie |

### Principes appliqués

| Principe RGPD | Application dans le système |
|---|---|
| **Minimisation des données** | Les sections absentes (ex. `nameSignature` hors onglet `"text"`, `description` vide) ne sont pas incluses dans le JSON |
| **Maîtrise utilisateur** | L'utilisateur choisit explicitement d'exporter un fichier ou de sauvegarder |
| **Effacement** | La suppression d'une carte retire les données du `localStorage`; la fermeture de l'onglet détruit les données en mémoire |
| **Portabilité** | Le format JSON structuré répond à l'obligation de portabilité (Art. 20 RGPD) |

### Points de vigilance

- La **signature manuscrite numérisée** (strokes de dessin ou image importée) peut être qualifiée de **donnée biométrique** selon le contexte d'usage. En cas d'usage dans un système documentaire d'entreprise, une analyse d'impact (AIPD) peut être nécessaire.
- Le fichier JSON exporté doit être traité comme un document sensible : ne pas le stocker dans des emplacements non sécurisés, ne pas le transmettre par email en clair.
- Le `localStorage` n'est **pas chiffré**. Sur un poste partagé, les données y sont accessibles par tout autre script du même domaine.

---

## 6. Contrôle des flux de données entre logiciels

### Architecture des flux

```
┌─────────────────────────────────────────────────────────────────┐
│                     NAVIGATEUR (client)                         │
│                                                                 │
│  ┌──────────────┐    export JSON    ┌──────────────────────┐   │
│  │  Application │ ───────────────▶  │  Fichier .json local │   │
│  │  Signature   │ ◀───────────────  │  (disque utilisateur)│   │
│  │  (Vue.js)    │    import JSON    └──────────────────────┘   │
│  │              │                                               │
│  │              │   localStorage    ┌──────────────────────┐   │
│  │              │ ◀────────────────▶│  Stockage navigateur │   │
│  └──────────────┘                   └──────────────────────┘   │
│                                                                 │
│  ✅ Aucun flux sortant vers un serveur externe                  │
└─────────────────────────────────────────────────────────────────┘
```

### Flux supportés

| Flux | Direction | Format | Déclencheur |
|---|---|---|---|
| Export vers fichier | Application → Disque local | `.json` | Action utilisateur explicite |
| Import depuis fichier | Disque local → Application | `.json` | Sélection de fichier par l'utilisateur |
| Sauvegarde locale | Application → `localStorage` | JSON sérialisé | Automatique à chaque modification des cartes |
| Chargement local | `localStorage` → Application | JSON désérialisé | Initialisation du composant |
| Export image | Application → Disque local | `.png` / `.svg` | Action utilisateur explicite |

### Intégration avec d'autres logiciels

Le JSON exporté est un format ouvert et auto-documenté. Il peut être consommé par :

- **Un autre navigateur / poste** : import direct du fichier `.json`
- **Un système de gestion documentaire** : lecture du champ `signatureTitle`, `nameSignature` pour indexation
- **Un outil de traitement d'images** : extraction du champ `signature.importedImage.imageDataUrl` (base64 → PNG)
- **Un script d'administration** : reconstruction programmatique d'une signature à partir des champs de style

### Garanties d'intégrité à l'import

- Le champ `version` permet de gérer les migrations de schéma futures.
- Tous les champs sont optionnels côté import (type `Partial<SignatureConfigJson>`).
- Les valeurs inconnues ou invalides sont ignorées et remplacées par des défauts sûrs.
- L'import ne peut pas provoquer d'erreur d'exécution — l'ensemble du traitement est protégé.

### Ce qui n'est PAS transmis

- Aucune donnée **réseau** (pas de `fetch`, `XHR`, `WebSocket`).
- Aucune donnée vers des **services tiers** (analytics, CDN, etc.) lors de l'import/export.
- Aucun **cookie** n'est utilisé pour la persistance des signatures.

---

## 7. Fichiers sources concernés

| Fichier | Rôle |
|---|---|
| [useSignatureExport.ts](src/components/signature/useSignatureExport.ts) | Hook de génération et téléchargement du JSON (et PNG/SVG) |
| [useSignatureJsonImport.ts](src/components/signature/useSignatureJsonImport.ts) | Hook de lecture, validation et hydration depuis un JSON ; exporte aussi `useJsonImportHandler` |
| [useSignatureStorage.ts](src/components/signature/useSignatureStorage.ts) | Gestion `localStorage` : CRUD des cartes, signature par défaut, génération aperçu SVG |
| [types.ts](src/components/signature/types.ts) | Définition de l'interface `SignatureConfigJson`, `StampConfig` et des types associés |
| [SelectSignature.vue](src/components/modals/SelectSignature.vue) | Orchestration UI des cartes sauvegardées, délègue la persistance à `useSignatureStorage` |
| [SignatureCreatorPanel.vue](src/components/elements/SignatureCreatorPanel.vue) | Panneau principal de création/édition ; point d'entrée principal export/import JSON |
