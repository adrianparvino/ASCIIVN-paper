{ pkgs
, biber
, emacs25WithPackages
, texlive
, stdenv
}:

let
  emacs = emacs25WithPackages (pkgs: with pkgs; [ org org-ref ]);
  tex = texlive.combine {
  inherit (texlive) scheme-basic apa biblatex-biblatex capt collection
    csquotes datatool datetime enumitem etoolbox float fmtcount-fonts
    fontspec fontsrecommended fp glossaries latex listings logreq mathtools
    mfirstuc ms of pdfpages pgf pgfgantt-setspace siunitx
    substr-textcase titlesec tocloft tracklang ulem
    wrapfig xcolor xetex xfor xkeyval xstring;
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
