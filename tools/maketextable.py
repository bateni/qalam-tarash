import argparse
import os
import fontforge


TEX_HEADER = """
\\documentclass{article}
\\usepackage{fullpage}
\\renewcommand{\\arraystretch}{1.5}
\\begin{document}
\\LARGE
\\font\\test="[%s]" at 16pt
\\test
"""

TEX_FOOTER = """
\\end{document}
"""


def TeXtt(s):
    return '\\texttt{%s}' % s


def TeXbf(s):
    return '{\\bf %s}' % s


def printCodePage(code_page, glyph_set):
    print '\\centerline{\\begin{tabular}{|' + 'c|'*(1+16) + '}'
    # header
    print '\\cline{2-17}'
    print '\\multicolumn{1}{c|}{}'
    for col in range(16):
        print '&' + TeXtt('%X' % col)
    print '\\\\'
    # rows
    for row in range(16):
        print '\\hline'
        print TeXtt('%03Xx' % (16 * code_page + row))
        for col in range(16):
            char_code = 256 * code_page + 16 * row + col
            print '&' + ('\\char"%X' % char_code 
                         if char_code in glyph_set else '')
        print '\\\\'        
    print '\\hline'
    print '\\end{tabular}}\n\\newpage'


def makeTexSource(font_file):
    """Builds the TeX source for the font."""

    font = fontforge.open(font_file)
    font.encoding = 'unicode'
    glyph_list = []
    for glyph in font.glyphs():
        glyph_list.append(glyph.unicode)
    glyph_list = set(glyph_list)
    glyph_pages = []
    print TEX_HEADER % font_file
    for x in sorted(glyph_list):
        if x < 0:
            continue
        code_page = x / 256
        if len(glyph_pages) == 0 or glyph_pages[-1] != code_page:
            glyph_pages.append(code_page)
            printCodePage(code_page, glyph_list)
    print TEX_FOOTER


def main():
    parser = argparse.ArgumentParser(description="Create a source to generate font tables in TeX.")
    parser.add_argument("--font", metavar="FILE", help="input font to process", required=True)

    args = parser.parse_args()

    makeTexSource(args.font)

if __name__ == "__main__":
    main()
