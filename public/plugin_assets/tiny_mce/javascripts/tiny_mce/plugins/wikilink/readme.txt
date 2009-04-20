This is a tiny_mce plugin for simple and easy wiki links.

No Popups!      You can edit the link href attribute without a popup.
1-click links!  You can create a link from selected text with a single click.
0-click links!  You can make the current word a link with a shortcut key.

Setup:
	tinyMCE.init({
		...
		plugins : "wikilink",
		...
		theme_advanced_buttons1 : "wikilink,wikientry",
		...
		wikilink_style: 'trim,camelcase', // trim is default
	});

This will create a wikilink button and a wikientry textbox in the toolbar.

Wikilink button:  When clicked, the current selection is made into a link,
with the text of the selection as the contents of the href attribute.
Control-L is the shortcut key for activating the button.

Wikientry:  When the cursor is on a link node, the value of its href 
attribute is displayed in the textbox, and can be edited there directly.
(without waiting for some bloated dialog to load)
Deleting the href value will remove the link.

If nothing is selected when the wikilink button is clicked (or the shortcut
key is pressed), the word at the cursor is selected and made into a link.

The "wikilink_style" parameter controls how the value for the href attribute
is processed.  The default style is "trim".  Combinations of more than one
style are useful and supported.
	Verbatim: disable all filters
	StripNonWord: remove all punctuation
	Trim: remove begin/end punctuation and excess internal spaces
	LowerCase: convert to lower case
	CamelCase: do CamelCaseConversion
	StripSpace: remove all spaces

Hopefully someone finds this useful.

Patches welcome!

John Williams <smailliw@gmail.com>

