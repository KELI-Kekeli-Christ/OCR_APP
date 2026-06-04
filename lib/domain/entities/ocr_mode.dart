enum OcrMode {
  document,
  freeText,
  table,
  math,
  handwriting,
  businessCard,
  administrative,
  student,
}

extension OcrModeX on OcrMode {
  String get label => switch (this) {
        OcrMode.document => 'Document',
        OcrMode.freeText => 'Texte libre',
        OcrMode.table => 'Tableaux',
        OcrMode.math => 'Mathématiques',
        OcrMode.handwriting => 'Manuscrit',
        OcrMode.businessCard => 'Carte de visite',
        OcrMode.administrative => 'Administratif',
        OcrMode.student => 'Mode étudiant',
      };

  String get deepSeekPrompt => switch (this) {
        OcrMode.document =>
          '<image>\n<|grounding|>Convert the document to markdown.',
        OcrMode.freeText => '<image>\nFree OCR.',
        OcrMode.table =>
          '<image>\n<|grounding|>Convert the document to markdown. Preserve all tables in markdown format.',
        OcrMode.math =>
          '<image>\n<|grounding|>Convert the document to markdown. Preserve all mathematical equations in LaTeX format using \$ and \$\$ delimiters.',
        OcrMode.handwriting =>
          '<image>\n<|grounding|>Recognize handwritten text and convert to markdown.',
        OcrMode.businessCard =>
          '<image>\nExtract contact information from this business card as structured markdown.',
        OcrMode.administrative =>
          '<image>\n<|grounding|>Convert this administrative document to structured markdown.',
        OcrMode.student =>
          '<image>\n<|grounding|>Convert academic content to markdown with LaTeX for equations.',
      };

  String get iconName => switch (this) {
        OcrMode.document => 'description',
        OcrMode.freeText => 'text_fields',
        OcrMode.table => 'table_chart',
        OcrMode.math => 'functions',
        OcrMode.handwriting => 'draw',
        OcrMode.businessCard => 'contact_page',
        OcrMode.administrative => 'folder_special',
        OcrMode.student => 'school',
      };
}
