{ pkgs
, biber
, emacs25WithPackages
, texlive
, stdenv
}:

let
  emacs = emacs25WithPackages (pkgs: with pkgs; [ org org-ref ]);
  tex = texlive.combine {
  inherit (texlive) scheme-basic koma-script stmaryrd booktabs
    paralist framed fontspec luatex85 luatex luaotfload float
    lualibs euenc titlesec tabu varwidth xypic standalone enumitem
    xetex xkeyval currfile filehook tocloft pgf ms xcolor glossaries
    mfirstuc etoolbox textcase xfor datatool substr fp exam
    latex-fonts collection-fontsrecommended easylist soul tracklang
    pgfplots biblatex apacite biblatex-apa logreq xstring biber
    picinpar wrapfig ulem capt-of usebib biblatex-mla setspace
    mathtools ucs multirow sectsty pgfgantt beamer listings pdfpages
    etoc microtype luatexbase ctablestack siunitx dvipng metafont
    datetime fmtcount csquotes latexmk;
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
