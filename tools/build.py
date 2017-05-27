#!/usr/bin/env python
# encoding: utf-8

import argparse
import os
import unicodedata
import fontforge


class MergeType:
    """ Used for internal representation of the merge request:
    NONE: don't merge the Latin font at all,
    PLAIN: use fontforge.mergeFonts(), or
    DEEP: look inside the Latin font and cherry-pick the useful stuff. """
    NONE, PLAIN, DEEP = range(3)
    
    @classmethod
    def fromstring(cls, str):
        return getattr(cls, str.upper(), MergeType.NONE)


def mergeLatinFont(orig_font, args):
    """ 'args.latin_file' argument points to a font from which Latin glyphs
    are taken and added to 'orig_font' as dictated by 'args.merge_type' and
    other 'args' options. """
    if args.merge_type == MergeType.PLAIN:
        orig_font.mergeFonts(args.latin_file)
    elif args.merge_type == MergeType.DEEP:
        # This only merges a-zA-Z, but could be extended.
        latin_font = fontforge.open(args.latin_file)
        latin_font.selection.select(("ranges",),"a","z")
        latin_font.selection.select(("ranges","more"),"A","Z")
        latin_font.copy()
        orig_font.selection.select(("ranges",),'a','z')
        orig_font.selection.select(("ranges","more"),"A","Z")
        orig_font.paste()
    return orig_font


def changeLatinDigits(font, args):
    if not args.digits_feature_file:
        return
    digits = [ 'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine' ]
    for i, c in enumerate(digits):
        font.createChar(0x30 + i, c)
    font.mergeFeature(args.digits_feature_file)


def build(args):
    font = fontforge.open(args.arabic_file)
    font.encoding = 'unicode'
    mergeLatinFont(font, args)
    changeLatinDigits(font, args)
    return font


def make_dir_p(directory):
    if not os.path.isdir(directory):
        os.makedirs(directory) 


def main():
    parser = argparse.ArgumentParser(description="Build Sahel fonts.")
    parser.add_argument("--arabic-file", metavar="FILE", help="input arabic font to process", required=True)
    parser.add_argument("--latin-file", metavar="FILE", help="input latin font to process")
    parser.add_argument("--out-file", metavar="FILE", help="output font to write", required=True)
    parser.add_argument("--feature-file", metavar="FILE", help="input features to use")
    parser.add_argument("--digits-feature-file", metavar="FILE", help="input features to use for digits")
    parser.add_argument("--merge-type", type=MergeType.fromstring, help="whether 'fontforge.mergeFonts' is to be use")

    args = parser.parse_args()

    font = build(args)
    make_dir_p(os.path.dirname(args.out_file))
    font.generate(args.out_file)

if __name__ == "__main__":
    main()
