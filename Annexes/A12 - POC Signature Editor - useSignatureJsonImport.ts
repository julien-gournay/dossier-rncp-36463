import type { Ref } from "vue";
import { 
  useToast
} from "@neoledge/vue-ui";
import type {
  DrawingStroke,
  SignatureConfigJson,
  SignatureTab,
  TextAlignment,
} from "@/components/signature/types";
import {
  asBoolean,
  asNumber,
  asString,
  cloneStrokes,
  isAlignment,
  renderStrokesToDataUrl,
  toFontChoice,
} from "@/components/signature/utils";

function validateSignatureJson(payload: Partial<SignatureConfigJson>): string | null {
  const sig = payload.signature;

  const hasText =
    payload.nameSignature &&
    (payload.nameSignature.firstName?.trim() || payload.nameSignature.lastName?.trim());

  const hasDraw =
    sig?.source === "draw" &&
    Array.isArray(sig.draw?.strokes) &&
    sig.draw.strokes.length > 0;

  const hasImport =
    sig?.source === "import" &&
    sig.importedImage?.imageDataUrl?.trim();

  if (!hasText && !hasDraw && !hasImport) {
    return "Le fichier JSON ne contient aucune signature valide.";
  }
  return null;
}

interface UseSignatureJsonImportOptions {
  selectedTab: Ref<SignatureTab>;
  exportWithBackground: Ref<boolean>;
  nameFieldValue: Ref<string>;
  lastNameFieldValue: Ref<string>;
  showAbbreviatedName: Ref<boolean>;
  signatureFont: Ref<string>;
  signatureColor: Ref<string>;
  signatureSize: Ref<number>;
  signatureAlignment: Ref<TextAlignment>;
  signatureBold: Ref<boolean>;
  signatureItalic: Ref<boolean>;
  signatureUnderline: Ref<boolean>;
  topContentValue: Ref<string>;
  topContentFont: Ref<string>;
  topContentColor: Ref<string>;
  topContentSize: Ref<number>;
  topContentAlignment: Ref<TextAlignment>;
  topContentBold: Ref<boolean>;
  topContentItalic: Ref<boolean>;
  topContentUnderline: Ref<boolean>;
  showTopContent: Ref<boolean>;
  bottomContentValue: Ref<string>;
  additionalTextFont: Ref<string>;
  textColor: Ref<string>;
  textSize: Ref<number>;
  textAlignment: Ref<TextAlignment>;
  bottomContentBold: Ref<boolean>;
  bottomContentItalic: Ref<boolean>;
  bottomContentUnderline: Ref<boolean>;
  showBottomContent: Ref<boolean>;
  signatureSource: Ref<"none" | "draw" | "import">;
  drawnSignatureStrokes: Ref<DrawingStroke[]>;
  drawingCanvasWidth: Ref<number>;
  drawingCanvasHeight: Ref<number>;
  signatureImageData: Ref<string>;
  importedFileName: Ref<string>;
  drawingCanvasKey: Ref<number>;
  actionMessage: Ref<string>;
  renderPreview: () => void;
}

export function useSignatureJsonImport(options: UseSignatureJsonImportOptions) {
  const toast = useToast();

  const {
    selectedTab,
    exportWithBackground,
    nameFieldValue,
    lastNameFieldValue,
    showAbbreviatedName,
    signatureFont,
    signatureColor,
    signatureSize,
    signatureAlignment,
    signatureBold,
    signatureItalic,
    signatureUnderline,
    topContentValue,
    topContentFont,
    topContentColor,
    topContentSize,
    topContentAlignment,
    topContentBold,
    topContentItalic,
    topContentUnderline,
    showTopContent,
    bottomContentValue,
    additionalTextFont,
    textColor,
    textSize,
    textAlignment,
    bottomContentBold,
    bottomContentItalic,
    bottomContentUnderline,
    showBottomContent,
    signatureSource,
    drawnSignatureStrokes,
    drawingCanvasWidth,
    drawingCanvasHeight,
    signatureImageData,
    importedFileName,
    drawingCanvasKey,
    actionMessage,
    renderPreview: renderPreviewFn,
  } = options;

  function loadSignatureFromJson(
    payload: Partial<SignatureConfigJson>,
  ): boolean {
    const validationError = validateSignatureJson(payload);
    if (validationError) {
      console.error(validationError);
      toast.error({ title: 'JSON invalide', message: validationError, position: 'top-right', showProgress: true });
      return false;
    }

    const nextTab = payload.selectedTab;
    if (nextTab === "text" || nextTab === "draw" || nextTab === "import") {
      selectedTab.value = nextTab;
    }

    exportWithBackground.value = asBoolean(
      payload.exportWithBackground,
      true,
    );

    const importedName = payload.nameSignature;
    if (importedName) {
      nameFieldValue.value = asString(importedName.firstName);
      lastNameFieldValue.value = asString(importedName.lastName);
      showAbbreviatedName.value = asBoolean(
        importedName.abbreviated,
        false,
      );

      const font = toFontChoice(importedName.style?.font);
      if (font) signatureFont.value = font;
      signatureColor.value = asString(importedName.style?.color, "#000000");
    }

    const importedTop = payload.topContent;
    if (importedTop) {
      showTopContent.value = asBoolean(importedTop.enabled, false);
      topContentValue.value = asString(importedTop.value);
      const font = toFontChoice(importedTop.style?.font);
      if (font) topContentFont.value = font;
      topContentColor.value = asString(importedTop.style?.color, "#000000");
      topContentSize.value = asNumber(importedTop.style?.size, 14);
      if (isAlignment(importedTop.style?.alignment)) {
        topContentAlignment.value = importedTop.style.alignment;
      }
      topContentBold.value = asBoolean(importedTop.style?.bold, false);
      topContentItalic.value = asBoolean(importedTop.style?.italic, false);
      topContentUnderline.value = asBoolean(
        importedTop.style?.underline,
        false,
      );
    }

    const importedBottom = payload.bottomContent;
    if (importedBottom) {
      showBottomContent.value = asBoolean(importedBottom.enabled, false);
      bottomContentValue.value = asString(importedBottom.value);
      const font = toFontChoice(importedBottom.style?.font);
      if (font) additionalTextFont.value = font;
      textColor.value = asString(importedBottom.style?.color, "#000000");
      textSize.value = asNumber(importedBottom.style?.size, 14);
      if (isAlignment(importedBottom.style?.alignment)) {
        textAlignment.value = importedBottom.style.alignment;
      }
      bottomContentBold.value = asBoolean(importedBottom.style?.bold, false);
      bottomContentItalic.value = asBoolean(
        importedBottom.style?.italic,
        false,
      );
      bottomContentUnderline.value = asBoolean(
        importedBottom.style?.underline,
        false,
      );
    }

    const importedSignature = payload.signature;
    const source = importedSignature?.source;
    signatureSource.value =
      source === "draw" || source === "import" ? source : "none";

    if (signatureSource.value === "draw") {
      const strokes = Array.isArray(importedSignature?.draw?.strokes)
        ? importedSignature?.draw?.strokes
        : [];
      drawnSignatureStrokes.value = cloneStrokes(
        strokes as DrawingStroke[],
      );
      drawingCanvasWidth.value = asNumber(
        importedSignature?.draw?.width,
        800,
      );
      drawingCanvasHeight.value = asNumber(
        importedSignature?.draw?.height,
        200,
      );
      signatureImageData.value = renderStrokesToDataUrl(
        drawnSignatureStrokes.value,
        drawingCanvasWidth.value,
        drawingCanvasHeight.value,
      );
      importedFileName.value = "";
    } else if (signatureSource.value === "import") {
      drawnSignatureStrokes.value = [];
      importedFileName.value = asString(
        importedSignature?.importedImage?.fileName,
      );
      signatureImageData.value = asString(
        importedSignature?.importedImage?.imageDataUrl,
      );
    } else {
      drawnSignatureStrokes.value = [];
      importedFileName.value = "";
      signatureImageData.value = "";
    }

    drawingCanvasKey.value += 1;
    return true;
  }

  const handleJsonImportFile = useJsonImportHandler((parsed, fileName) => {
    const success = loadSignatureFromJson(parsed);
    if (success) {
      actionMessage.value = "Signature importée avec succès.";
      toast.success({ title: 'Succès', message: `Le fichier "${fileName}" a été importé avec succès.`, position: 'top-right', showProgress: true });
      renderPreviewFn();
    }
  });

  return {
    loadSignatureFromJson,
    handleJsonImportFile,
  };
}

export function useJsonImportHandler(
  onSuccess: (parsed: Partial<SignatureConfigJson>, fileName: string) => void,
): (event: Event) => void {
  const toast = useToast();

  return function handleJsonFile(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;

    const isJson = file.type === "application/json" || file.name.toLowerCase().endsWith(".json");
    if (!isJson) {
      toast.error({ title: 'Erreur format', message: 'Veuillez importer un fichier JSON.', position: 'top-right', showProgress: true });
      input.value = "";
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      try {
        const parsed = JSON.parse(String(reader.result ?? "{}")) as Partial<SignatureConfigJson>;
        const error = validateSignatureJson(parsed);
        if (error) {
          toast.error({ title: 'Signature introuvable', message: error, position: 'top-right', showProgress: true });
          return;
        }
        onSuccess(parsed, file.name);
      } catch {
        toast.error({ title: 'Erreur', message: "Le fichier n'est pas un JSON valide.", position: 'top-right', showProgress: true });
      } finally {
        input.value = "";
      }
    };
    reader.readAsText(file);
  };
}
