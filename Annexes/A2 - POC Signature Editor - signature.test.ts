import { describe, it, expect, beforeEach, vi } from 'vitest'

// @neoledge/vue-ui's UMD build requires a global Vue instance, which isn't
// available in the test environment. Stub it so importing useSignatureStorage
// (which only calls useToast inside composable functions, not at module scope)
// doesn't crash on import.
vi.mock('@neoledge/vue-ui', () => ({
  useToast: () => ({ success: () => {}, error: () => {} }),
}))
import {
  asString,
  asNumber,
  asBoolean,
  toFontChoice,
  isAlignment,
  resolveColor,
  escapeSvgText,
  getTextLines,
  getLineHeight,
  cloneStrokes,
} from '@/components/signature/utils'
import {
  buildSignatureCardName,
  loadFromStorage,
  STORAGE_KEY,
  STORAGE_ID_KEY,
} from '@/components/signature/useSignatureStorage'
import type { SignatureConfigJson } from '@/components/signature/types'

// =============================================================================
// SUITE 1 – Utilitaires de validation (src/components/signature/utils.ts)
// =============================================================================
describe('asString', () => {
  it('retourne la valeur si string non vide', () => {
    expect(asString('Arial', 'défaut')).toBe('Arial')
  })
  it('retourne la valeur si string vide', () => {
    expect(asString('', 'défaut')).toBe('')
  })
  it('retourne le défaut si null', () => {
    expect(asString(null, 'défaut')).toBe('défaut')
  })
  it('retourne le défaut si undefined', () => {
    expect(asString(undefined, 'défaut')).toBe('défaut')
  })
  it('retourne "" si undefined sans défaut fourni', () => {
    expect(asString(undefined)).toBe('')
  })
  it('retourne le défaut si nombre', () => {
    expect(asString(42, 'défaut')).toBe('défaut')
  })
  it('retourne le défaut si objet', () => {
    expect(asString({}, 'défaut')).toBe('défaut')
  })
})

describe('asNumber', () => {
  it('retourne le nombre si entier valide', () => {
    expect(asNumber(14, 12)).toBe(14)
  })
  it('retourne le nombre si décimal valide', () => {
    expect(asNumber(1.5, 1)).toBe(1.5)
  })
  it('retourne le nombre si zéro', () => {
    expect(asNumber(0, 12)).toBe(0)
  })
  it('retourne le défaut si NaN', () => {
    expect(asNumber(NaN, 12)).toBe(12)
  })
  it('retourne le défaut si Infinity', () => {
    expect(asNumber(Infinity, 12)).toBe(12)
  })
  it('retourne le défaut si string numérique (pas de parsing)', () => {
    expect(asNumber('14', 12)).toBe(12)
  })
  it('retourne le défaut si null', () => {
    expect(asNumber(null, 12)).toBe(12)
  })
  it('retourne le défaut si undefined', () => {
    expect(asNumber(undefined, 12)).toBe(12)
  })
})

describe('asBoolean', () => {
  it('retourne true si true', () => {
    expect(asBoolean(true, false)).toBe(true)
  })
  it('retourne false si false', () => {
    expect(asBoolean(false, true)).toBe(false)
  })
  it('retourne le défaut si string "true"', () => {
    expect(asBoolean('true', false)).toBe(false)
  })
  it('retourne le défaut si 1', () => {
    expect(asBoolean(1, false)).toBe(false)
  })
  it('retourne le défaut si null', () => {
    expect(asBoolean(null, true)).toBe(true)
  })
  it('retourne false par défaut si pas de fallback fourni', () => {
    expect(asBoolean(undefined)).toBe(false)
  })
})

describe('toFontChoice', () => {
  it('accepte Arial', () => {
    expect(toFontChoice('Arial')).toBe('Arial')
  })
  it('accepte Georgia', () => {
    expect(toFontChoice('Georgia')).toBe('Georgia')
  })
  it('accepte Courier New', () => {
    expect(toFontChoice('Courier New')).toBe('Courier New')
  })
  it('accepte Times New Roman', () => {
    expect(toFontChoice('Times New Roman')).toBe('Times New Roman')
  })
  it('accepte Ms Madi', () => {
    expect(toFontChoice('Ms Madi')).toBe('Ms Madi')
  })
  it('retourne null si police inconnue', () => {
    expect(toFontChoice('Comic Sans')).toBeNull()
  })
  it('retourne null si null', () => {
    expect(toFontChoice(null)).toBeNull()
  })
  it('retourne null si string vide', () => {
    expect(toFontChoice('')).toBeNull()
  })
})

describe('isAlignment', () => {
  it('accepte left', () => {
    expect(isAlignment('left')).toBe(true)
  })
  it('accepte center', () => {
    expect(isAlignment('center')).toBe(true)
  })
  it('accepte right', () => {
    expect(isAlignment('right')).toBe(true)
  })
  it('rejette une valeur inconnue', () => {
    expect(isAlignment('justify')).toBe(false)
  })
  it('rejette null', () => {
    expect(isAlignment(null)).toBe(false)
  })
  it('rejette undefined', () => {
    expect(isAlignment(undefined)).toBe(false)
  })
})

describe('resolveColor', () => {
  it('retourne la couleur si string non vide', () => {
    expect(resolveColor('#1F3864', '#000000')).toBe('#1F3864')
  })
  it('retourne le défaut si string vide', () => {
    expect(resolveColor('', '#000000')).toBe('#000000')
  })
  it('retourne le défaut si null', () => {
    expect(resolveColor(null, '#000000')).toBe('#000000')
  })
  it('extrait hex depuis un objet', () => {
    expect(resolveColor({ hex: '#FFFFFF' }, '#000000')).toBe('#FFFFFF')
  })
  it('extrait value depuis un objet', () => {
    expect(resolveColor({ value: '#ABCDEF' }, '#000000')).toBe('#ABCDEF')
  })
})

describe('escapeSvgText', () => {
  it('échappe les caractères spéciaux XML', () => {
    expect(escapeSvgText('<b>A & "B" \'C\'</b>')).toBe(
      '&lt;b&gt;A &amp; &quot;B&quot; &apos;C&apos;&lt;/b&gt;',
    )
  })
  it("ne modifie pas un texte sans caractère spécial", () => {
    expect(escapeSvgText('Julien Gournay')).toBe('Julien Gournay')
  })
})

describe('getTextLines', () => {
  it('filtre les lignes vides', () => {
    expect(getTextLines('Ligne 1\n\nLigne 2')).toEqual(['Ligne 1', 'Ligne 2'])
  })
  it('limite à 3 lignes maximum', () => {
    expect(getTextLines('a\nb\nc\nd')).toEqual(['a', 'b', 'c'])
  })
  it('retourne un tableau vide pour une chaîne vide', () => {
    expect(getTextLines('')).toEqual([])
  })
})

describe('getLineHeight', () => {
  it('arrondit la taille * 1.25', () => {
    expect(getLineHeight(14)).toBe(18)
  })
  it('gère une taille de 0', () => {
    expect(getLineHeight(0)).toBe(0)
  })
})

describe('cloneStrokes', () => {
  it('produit une copie profonde des traits', () => {
    const strokes = [{ color: '#000', size: 2, points: [{ x: 1, y: 2 }] }]
    const cloned = cloneStrokes(strokes)
    expect(cloned).toEqual(strokes)
    expect(cloned).not.toBe(strokes)
    expect(cloned[0]).not.toBe(strokes[0])
    expect(cloned[0]?.points[0]).not.toBe(strokes[0]?.points[0])
  })
})


// =============================================================================
// SUITE 2 – buildSignatureCardName (src/components/signature/useSignatureStorage.ts)
// =============================================================================
describe('buildSignatureCardName', () => {
  it('utilise signatureTitle si renseigné', () => {
    const payload: Partial<SignatureConfigJson> = { signatureTitle: 'Ma signature' }
    expect(buildSignatureCardName(payload)).toBe('Ma signature')
  })

  it('utilise prénom + nom si signatureTitle absent', () => {
    const payload: Partial<SignatureConfigJson> = {
      nameSignature: {
        firstName: 'Julien',
        lastName: 'Gournay',
        abbreviated: false,
        style: { font: 'Arial', color: '#000000' },
      },
    }
    expect(buildSignatureCardName(payload)).toBe('Julien Gournay')
  })

  it('priorise le nom complet même si abbreviated est true', () => {
    const payload: Partial<SignatureConfigJson> = {
      nameSignature: {
        firstName: 'Julien',
        lastName: 'Gournay',
        abbreviated: true,
        style: { font: 'Arial', color: '#000000' },
      },
    }
    expect(buildSignatureCardName(payload)).toBe('Julien Gournay')
  })

  it('retourne "Nouvelle signature" pour un dessin sans nom', () => {
    const payload: Partial<SignatureConfigJson> = { selectedTab: 'draw' }
    expect(buildSignatureCardName(payload)).toBe('Nouvelle signature')
  })

  it('retourne "Signature importée" par défaut', () => {
    const payload: Partial<SignatureConfigJson> = { selectedTab: 'import' }
    expect(buildSignatureCardName(payload)).toBe('Signature importée')
  })
})


// =============================================================================
// SUITE 3 – localStorage (persistance des cartes sauvegardées)
// =============================================================================
describe('loadFromStorage – signature_saved_cards', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('retourne un tableau vide et nextId 1 si clé absente', () => {
    const { cards, nextId } = loadFromStorage()
    expect(cards).toEqual([])
    expect(nextId).toBe(1)
  })

  it('lit les cartes et le prochain id depuis localStorage', () => {
    const stored = [{ id: 1, name: 'Julien Gournay' }]
    localStorage.setItem(STORAGE_KEY, JSON.stringify(stored))
    localStorage.setItem(STORAGE_ID_KEY, '2')

    const { cards, nextId } = loadFromStorage()
    expect(cards).toHaveLength(1)
    expect(cards[0].name).toBe('Julien Gournay')
    expect(nextId).toBe(2)
  })

  it('retourne un état vide si le JSON stocké est invalide', () => {
    localStorage.setItem(STORAGE_KEY, '{invalid json')
    const { cards, nextId } = loadFromStorage()
    expect(cards).toEqual([])
    expect(nextId).toBe(1)
  })

  it('permet de supprimer une carte par id', () => {
    const cards = [
      { id: 1, name: 'Carte 1' },
      { id: 2, name: 'Carte 2' },
      { id: 3, name: 'Carte 3' },
    ]
    localStorage.setItem(STORAGE_KEY, JSON.stringify(cards))
    const updated = cards.filter((c) => c.id !== 2)
    localStorage.setItem(STORAGE_KEY, JSON.stringify(updated))

    const { cards: stored } = loadFromStorage()
    expect(stored).toHaveLength(2)
    expect(stored.find((c: { id: number }) => c.id === 2)).toBeUndefined()
  })

  it('supporte plusieurs cartes en parallèle', () => {
    const cards = Array.from({ length: 10 }, (_, i) => ({ id: i + 1, name: `Carte ${i + 1}` }))
    localStorage.setItem(STORAGE_KEY, JSON.stringify(cards))

    const { cards: stored } = loadFromStorage()
    expect(stored).toHaveLength(10)
  })
})
