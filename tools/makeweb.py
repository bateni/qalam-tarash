import argparse
import os

from fontTools.ttLib import TTFont
from fontTools import subset

def makeWeb(args):
    """ Generate TTF/WOFF/WOFF2 fonts """

    font = TTFont(args.file)
    ## TODO: We can remove specialized glyphs, stylistic sets,
    ## etc. that are not useful on the web in order to minimize the
    ## file size.

    base, ext = os.path.splitext(args.file)
    base = os.path.basename(base)
    for flavor in ("ttf", "woff", "woff2"):
        if flavor is not "ttf":
            font.flavor = flavor
        font.save(args.dir + "/" + base + "." + flavor)
    font.close()


def main():
    parser = argparse.ArgumentParser(description="Create web optimised version of Sahel fonts.")
    parser.add_argument("file", help="input font to process")
    parser.add_argument("dir", help="output directory to write fonts to")

    args = parser.parse_args()

    makeWeb(args)

if __name__ == "__main__":
    main()
