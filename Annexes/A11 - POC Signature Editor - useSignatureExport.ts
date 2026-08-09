import type { Ref } from "vue";
import { PNG_EXPORT_SCALE } from "@/components/signature/constants";
import type {
  DrawingStroke,
  FontChoice,
  SignatureConfigJson,
  SignatureTab,
  TextAlignment,
} from "@/components/signature/types";
import { cloneStrokes, resolveColor } from "@/components/signature/utils";

interface UseSignatureExportParams {
  previewCanvasRef: Ref<HTMLCanvasElement | null>;
  selectedTab: Ref<SignatureTab>;
  exportWithBackground: Ref<boolean>;
  nameFieldValue: Ref<string>;
  lastNameFieldValue: Ref<string>;
  showAbbreviatedName: Ref<boolean>;
  initialsFieldValue: Ref<string>;
  signatureFont: Ref<FontChoice>;
  signatureColor: Ref<string>;
  signatureSize: Ref<number>;
  signatureAlignment: Ref<TextAlignment>;
  signatureBold: Ref<boolean>;
  signatureItalic: Ref<boolean>;
  signatureUnderline: Ref<boolean>;
  showTopContent: Ref<boolean>;
  topContentValue: Ref<string>;
  topContentFont: Ref<FontChoice>;
  topContentColor: Ref<string>;
  topContentSize: Ref<number>;
  topContentAlignment: Ref<TextAlignment>;
  topContentBold: Ref<boolean>;
  topContentItalic: Ref<boolean>;
  topContentUnderline: Ref<boolean>;
  showBottomContent: Ref<boolean>;
  bottomContentValue: Ref<string>;
  additionalTextFont: Ref<FontChoice>;
  textColor: Ref<string>;
  textSize: Ref<number>;
  textAlignment: Ref<TextAlignment>;
  bottomContentBold: Ref<boolean>;
  bottomContentItalic: Ref<boolean>;
  bottomContentUnderline: Ref<boolean>;
  signatureSource: Ref<"none" | "draw" | "import">;
  drawingCanvasWidth: Ref<number>;
  drawingCanvasHeight: Ref<number>;
  drawnSignatureStrokes: Ref<DrawingStroke[]>;
  importedFileName: Ref<string>;
  signatureImageData: Ref<string>;
  actionMessage: Ref<string>;
  drawSignatureContent: (
    context: CanvasRenderingContext2D,
    useBackground: boolean,
    layoutWidth?: number,
    layoutHeight?: number,
    showDebugBorders?: boolean,
  ) => Promise<void>;
  getAdaptiveExportHeight: (layoutWidth: number) => number;
  buildSignatureSvg: (layoutWidth?: number, layoutHeight?: number) => string;
}

export function useSignatureExport(params: UseSignatureExportParams) {
  // Log complet de l'objet de paramètres
  // console.log("Export Hook initialized. Available refs:", params);

  async function saveMethod(): Promise<void> {
    if (!params.previewCanvasRef.value) return;

    const exportWidth = params.previewCanvasRef.value.width;
    const exportHeight = params.getAdaptiveExportHeight(exportWidth);

    const exportCanvas = document.createElement("canvas");
    exportCanvas.width = exportWidth * PNG_EXPORT_SCALE;
    exportCanvas.height = exportHeight * PNG_EXPORT_SCALE;

    const exportContext = exportCanvas.getContext("2d");
    if (!exportContext) return;

    exportContext.scale(PNG_EXPORT_SCALE, PNG_EXPORT_SCALE);

    await params.drawSignatureContent(
      exportContext,
      params.exportWithBackground.value,
      exportWidth,
      exportHeight,
    );

    const link = document.createElement("a");
    link.href = exportCanvas.toDataURL("image/png");
    link.download = "signature-finale.png";
    link.click();

    params.actionMessage.value = '"Enregistrer" action clicked';
  }

  function saveSvgMethod(): void {
    if (!params.previewCanvasRef.value) return;

    const exportWidth = params.previewCanvasRef.value.width;
    const exportHeight = params.getAdaptiveExportHeight(exportWidth);
    const svg = params.buildSignatureSvg(exportWidth, exportHeight);
    const blob = new Blob([svg], { type: "image/svg+xml;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "signature-finale.svg";
    link.click();
    URL.revokeObjectURL(url);

    params.actionMessage.value = "SVG exporte avec succes.";
  }

  function saveJSONMethod(signatureName?: string, description?: string): void {
    // Traitement des valeurs de signatureName et description
    const trimmedSignatureName = signatureName?.trim() ?? "";
    const trimmedSignatureDescription = description?.trim() ?? "";

    console.log("Generating JSON export with current refs state:", {
         tab: params.selectedTab.value,
         source: params.signatureSource.value,
         description: description,
         name: params.nameFieldValue.value
     });

    // Initialisation des données de base
    const payload: any = {
      version: 1,
      exportedAt: new Date().toISOString(),
      signatureTitle: trimmedSignatureName,
      description: trimmedSignatureDescription || undefined,
      selectedTab: params.selectedTab.value,
      exportWithBackground: params.exportWithBackground.value,
      signature: {
        source: params.signatureSource.value,
      }
    };

    // Condition : Inclure nameSignature SEULEMENT si on est dans l'onglet "Text"
    if (params.selectedTab.value === "text") {
      payload.nameSignature = {
        firstName: params.nameFieldValue.value,
        lastName: params.lastNameFieldValue.value,
        abbreviated: params.showAbbreviatedName.value,
        initials: params.showAbbreviatedName.value ? params.initialsFieldValue.value : undefined,
        style: {
          font: params.signatureFont.value,
          color: resolveColor(params.signatureColor.value, "#000000"),
          // size: params.signatureSize.value,
          // alignment: params.signatureAlignment.value,
          // bold: params.signatureBold.value,
          // italic: params.signatureItalic.value,
          // underline: params.signatureUnderline.value,
        },
      };
    }

    // Condition : Inclure les contenus compl mentaires SEULEMENT s'ils sont activ s
    if (params.showTopContent.value) {
      payload.topContent = {
        enabled: params.showTopContent.value,
        value: params.topContentValue.value,
        style: {
          font: params.topContentFont.value,
          color: params.topContentColor.value,
          size: params.topContentSize.value,
          alignment: params.topContentAlignment.value,
          bold: params.topContentBold.value,
          italic: params.topContentItalic.value,
          underline: params.topContentUnderline.value,
        },
      };
    }
    if (params.showBottomContent.value) {
      payload.bottomContent = {
        enabled: params.showBottomContent.value,
        value: params.bottomContentValue.value,
        style: {
          font: params.additionalTextFont.value,
          color: params.textColor.value,
          size: params.textSize.value,
          alignment: params.textAlignment.value,
          bold: params.bottomContentBold.value,
          italic: params.bottomContentItalic.value,
          underline: params.bottomContentUnderline.value,
        },
      };
    }
    // Gestion des données spécifiques au dessin ou à l'import
    if (params.selectedTab.value === "draw") {
      payload.signature.draw = {
        width: params.drawingCanvasWidth.value,
        height: params.drawingCanvasHeight.value,
        strokes: cloneStrokes(params.drawnSignatureStrokes.value),
      };
    } else if (params.selectedTab.value === "import") {
      payload.signature.importedImage = {
        fileName: params.importedFileName.value,
        imageDataUrl: params.signatureImageData.value,
      };
    }

    // Export du Blob JSON
    const blob = new Blob([JSON.stringify(payload, null, 2)], {
      type: "application/json;charset=utf-8",
    });

    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `signature-${new Date().toISOString().slice(0, 10)}.json`;
    link.click();
    URL.revokeObjectURL(url);

    params.actionMessage.value = "JSON exporte avec succes.";
  }

  return {
    saveMethod,
    saveSvgMethod,
    saveJSONMethod,
  };
}