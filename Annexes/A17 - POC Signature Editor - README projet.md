# Signature Editor

Application Vue 3 permettant de creer, personnaliser, sauvegarder et exporter des signatures numrique.

## Fonctionnalites

### Flux principal — EliseFlow (`/elise-flow`)
Page principale integrant le panneau de creation et la liste des signatures sauvegardees cote a cote.

- Ouverture du panneau `SignatureCreatorPanel` pour creer ou modifier une signature
- Liste des cartes `SignatureCard` triee avec la signature par defaut en tete
- Champ titre et description a la sauvegarde
- Option "definir par defaut" a la creation
- Export PNG avec fond blanc optionnel depuis chaque carte

### Flux page Signature (`/`)
- Modale `SelectSignature` : deux onglets **Signature enregistree** / **Nouvelle signature**
- Meme logique de creation et de sauvegarde que le flux EliseFlow

### Panneau de creation — SignatureCreatorPanel
Composant unifie creation/edition, avec trois modes :

| Mode | Description |
|------|-------------|
| **Texte** | Prenom, nom, initiales ; choix police ; mode abrege (initiales seules) |
| **Dessin** | Trace libre a la souris ou au doigt (`DrawingCanvas`) |
| **Import image** | PNG / JPG / JPEG / SVG via `SignatureImageImporter` |

- Apercu en temps reel (`Preview`)
- Personnalisation : couleur, taille, alignement, gras/italique/souligne
- Contenu complementaire haut/bas avec styles independants (`RichEditor`)
- Suggestions rapides : Prenom, Nom, Date du jour, Lu et approuve, Bon pour accord, Signe a
- Option fond blanc et bordures debug
- Exports : PNG, SVG, JSON

### Tampon — AddStampSignature
- Modale d'ajout d'un tampon (PNG/SVG) sur la signature
- Position : gauche, droite ou centre (superposition)
- Reglages : echelle, opacite
- Export PNG de la composition finale (signature + tampon)

### Texte complementaire — AdditionalTextSignature
- Modale ouverte depuis une carte sauvegardee
- Deux zones `RichEditor` (contenu haut et bas) avec police et alignement independants
- Apercu combine signature + textes complementaires
- Export PNG et JSON v2

### Animation — SignatureAnimationModal
- Rejoue une signature dessinee de maniere animee a partir de son JSON

### Export / Import

| Format | Description |
|--------|-------------|
| PNG | Image haute resolution (fond blanc optionnel), avec tampon si present |
| SVG | Rendu vectoriel redimensionnable |
| JSON v1 | Configuration complete (source, styles, traits de dessin, image importee) |
| JSON v2 | JSON v1 enrichi des textes complementaires (top/bottom content) |

Import image accepte : PNG, JPG/JPEG, SVG.

## Architecture des composants

```text
App.vue (Vue Router)
  pages/
    SignaturePage.vue        # Route /
      SelectSignature.vue    # Modale selection & creation
    EliseFlowPage.vue        # Route /elise-flow
  elements/
    SignatureCreatorPanel.vue # Panneau unifie creation/edition
      Preview.vue            # Apercu temps reel (texte ou canvas)
      DrawingCanvas.vue      # Canvas de dessin libre
      SignatureImageImporter.vue
      ColorPicker.vue
      RichEditor.vue
    SignatureCard.vue        # Carte signature sauvegardee
  modals/
    AdditionalTextSignature.vue  # Textes haut/bas + export
    AddStampSignature.vue        # Ajout tampon + export
    AddImageSignature.vue        # Import image
    SignatureAnimationModal.vue  # Animation signature dessinee
```

## Composables metier

| Fichier | Role |
|---------|------|
| `useSignatureRenderer` | Dessin canvas, SVG, rendu adaptatif |
| `useSignatureExport` | Telechargement PNG, SVG, JSON |
| `useSignatureJsonImport` | Restauration etat depuis JSON |
| `useSignatureStorage` | Gestion des cartes (localStorage) : ajout, suppression, renommage, defaut, apercu |

## Stack Technique

- Vue 3 + TypeScript
- Vite + Vue Router
- @neoledge/vue-ui
- Sass
- Vitest + @vue/test-utils

## Prerequis

- Node.js : `^20.19.0 || >=22.12.0`
- npm

## Installation

```sh
npm install
```

## Scripts Disponibles

```sh
# Lancer en developpement
npm run dev

# Build production + type-check
npm run build

# Preview du build
npm run preview

# Type-check uniquement
npm run type-check

# Tests unitaires
npm run test

# Interface Vitest UI
npm run test:ui

# Couverture des tests
npm run test:coverage
```

## Routes

| Route | Page | Description |
|-------|------|-------------|
| `/` | `SignaturePage` | Flux original avec modale SelectSignature |
| `/elise-flow` | `EliseFlowPage` | Flux EliseFlow integre (panneau + cartes) |

## Tests

```sh
npm run test        # Tests unitaires
npm run test:ui     # Interface graphique Vitest
```

Fichier de tests : `src/components/Signature.test.ts`

## Notes

- Certaines dependances `@neoledge/*` sont referencees via des fichiers locaux (`file:` dans `package.json`). En cas d'erreur sur un autre poste, verifier la disponibilite des archives locales.
- La persistance des cartes sauvegardees repose sur `localStorage` ; les donnees sont perdues si le stockage est efface.
- Les props `width` et `height` de `Preview.vue` servent de dimensions par defaut pour les modes `draw` et `importImage` (sans image) ; les autres modes calculent leur hauteur dynamiquement.
