# RichEditor

Éditeur de texte riche basé sur `contenteditable`, avec une barre d'outils intégrée pour la mise en forme du texte.

![RichEditor](demo/richEditor_1.png)

## Utilisation

```vue
<RichEditor
  id="top-editor"
  label="Description"
  placeholder="Saisissez votre texte..."
  :maxLines="3"    //3 lignes max dans l'editeur
  :max-chars-per-line="60"    //60 caractères max par ligne
  :tooltabs="true"
  :editable="true"
  :show-suggestions="true"
  :text-alignment="alignment"
  :font="font"
  :textColor="color"
  v-model="htmlContent"
  @update:font="topFont = $event"
  @update:text-alignment="topAlignment = $event"
/>
```

## Props

| Prop             | Type                              | Défaut      | Description                                                    |
|------------------|-----------------------------------|-------------|----------------------------------------------------------------|
| `modelValue`     | `string`                          | `''`        | Synchronisation du contenu HTML de l'éditeur (v-model)                            |
| `textColor`      | `string`                          | `'#1f2937'` | Couleur du texte sélectionné (v-model:textColor)               |
| `textAlignment`  | `'left' \| 'center' \| 'right'`   | `'left'`    | Alignement du texte (v-model:textAlignment)                    |
| `label`          | `string`                          | `''`        | Libellé affiché au-dessus de l'éditeur                         |
| `placeholder`    | `string`                          | `''`        | Texte affiché quand l'éditeur est vide                         |
| `maxLines`       | `number`                          | `0`         | Nombre maximum de lignes (0 = illimité)                        |
| `maxCharsPerLine`| `number`                          | `0`         | Nombre max de caractères par ligne (0 = illimité)              |
| `tooltabs`       | `boolean`                         | `true`      | Affiche ou masque la barre d'outils                            |
| `editable`       | `boolean`                         | `true`      | Active ou désactive l'édition (`contenteditable`)              |
| `font`           | `string`                          | `'Arial'`   | Police active affichée dans la barre d'outils (v-model:font)  |
| `showSuggestions`| `boolean`                         | `false`     | Affiche le composant `SuggestionTags` sous l'éditeur           |
| `firstName`      | `string`                          | `''`        | Prénom transmis à `SuggestionTags` (utilisé si `showSuggestions`) |
| `lastName`       | `string`                          | `''`        | Nom transmis à `SuggestionTags` (utilisé si `showSuggestions`)  |

## Événements

| Événement              | Payload                           | Description                              |
|------------------------|-----------------------------------|------------------------------------------|
| `update:modelValue`    | `string`                          | Émis à chaque modification du contenu    |
| `update:textColor`     | `string`                          | Émis lors du changement de couleur       |
| `update:textAlignment` | `'left' \| 'center' \| 'right'`   | Émis lors du changement d'alignement     |
| `update:font`          | `string`                          | Émis lors du changement de police        |

## Barre d'outils

La barre d'outils (visible si `tooltabs: true`) propose :

- **Taille** — via `FontSizeSelect` : 10px, 13px, 18px, 24px
- **Couleur** — via `ColorPicker` : sélecteur de couleur libre
- **Police** — dropdown : Arial, Georgia, Courier New, Times New Roman, Ms Madi
- **Alignement** — dropdown : Gauche, Milieu, Droite
- **Gras / Italique / Souligné** — boutons de style inline

## Comportement notable

- Le contenu est du **HTML brut** (`innerHTML`) — les styles sont injectés via `document.execCommand` avec `styleWithCSS`.
- Avec `maxLines`, la hauteur est fixe (`maxLines × 21px + 10px`) et la touche Entrée est bloquée une fois la limite atteinte.
- Le `v-model` se synchronise dans les deux sens : toute modification externe de `modelValue` met à jour l'éditeur.
- La prop `textColor` ne change que la couleur de la **sélection courante** (pas tout le contenu).

## Dépendances internes

- [ColorPicker.vue](src/components/ui//ColorPicker.vue)
- [FontSizeSelect.vue](src/components/ui/FontSizeSelect.vue)
- `@neoledge/vue-ui` — `NuiButton`, `NuiMenu`, `NuiDropdown`
