{ pkgs
, biber
, emacs25WithPackages
, texlive
, stdenv
}:

let
  emacs = emacs25WithPackages (pkgs: with pkgs; [ org org-ref ]);
  tex = texlive.combine {
  inherit (texlive) scheme-basic fontspec latex-fonts ms wrapfig
    xstring datetime csquotes biblatex fmtcount logreq biblatex-apa
    glossaries titlesec tocloft setspace pgfgantt float xfor ulem
    mathtools enumitem mfirstuc datatool substr capt-of xetex
    collection-fontsrecommended siunitx listings pdfpages etoolbox
    xkeyval textcase fp tracklang pgf xcolor;
  };
in
stdenv.mkDerivation {
  name = "Research.pdf";
  src = ./.;

  nativeBuildInputs = [ emacs biber tex ];

  buildPhase = ''
    emacs Research.org --batch --eval "(progn (package-initialize) (require 'org-ref) (org-latex-export-to-latex))" --kill

    xelatex Research.tex
    biber Research || true
    makeglossaries Research || true
    xelatex Research.tex
    xelatex Research.tex
  '';

  installPhase = ''
    mv Research.pdf $out
  '';
}
