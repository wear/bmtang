/**
 * $Id$
 *
 * @author John Williams
 * @copyright Copyleft © 2008 (Please copy!)
 */

(function() {
	// Load plugin specific language pack
	tinymce.PluginManager.requireLangPack('wikilink');

	tinymce.create('tinymce.plugins.WikilinkPlugin', {
	/**
	 * Initializes the plugin, this will be executed after the plugin has been created.
	 * This call is done before the editor instance has finished it's initialization so use the onInit event
	 * of the editor instance to intercept that event.
	 *
	 * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
	 * @param {string} url Absolute URL to where the plugin is located.
	 */
		init : function(ed, url) {
			// Register the command so that it can be invoked by using tinyMCE.activeEditor.execCommand('mceWikilink');
			ed.addCommand('mceWikilink', function() {
				// check if selection 
				//       or in link
				//       or use current word
				//   else do nothing
				var se = ed.selection;
				var elm = ed.dom.getParent(se.getNode(), 'A');

				// select current word if no selection or tag
				if (!elm && se.isCollapsed()) {
					var r = se.getRng();
					if (tinymce.isIE) {
						r.expand('word');
						se.setRng(r);
					} else {
/* see http://www.clipclip.org/wlt008/clips/email/1830/how-can-i-find-the-word-in-the-text-on-the-page-related-to-an-event-e-g-word-clicked-on-or-hovered 
var expandword = function /*expandRangeToWord*/ (range) {
  var startOfWord = /^\s\S+$/;
  var endOfWord = /^\S+\s$/;
  var whitespace = /^\s+$/;
  // if offset is inside whitespace
  range.setStart(range.startContainer, range.startOffset - 1);
  while (whitespace.test(range.toString())) {
    range.setEnd(range.endContainer, range.endOffset + 1);
    range.setStart(range.startContainer, range.startOffset + 1);
  }
  while (!startOfWord.test(range.toString())) {
    range.setStart(range.startContainer, range.startOffset - 1);
  }
  range.setStart(range.startContainer, range.startOffset + 1);
  while (!endOfWord.test(range.toString())) {
    range.setEnd(range.endContainer, range.endOffset + 1);
  }
  range.setEnd(range.endContainer, range.endOffset - 1);
  return range.toString();
};*/
var expandword = function (r) {
	var start = /^\s\S+$/;
	var end = /^\S+\s$/;
	var sc = r.startContainer, ec = r.endContainer;
	var so = r.startOffset, eo = r.endOffset;
	var sok = 0, eok = 0;

	so = so - 1;
	if (so < 0) { 
		r.setStartBefore(sc);
		sc = r.startContainer;
		so = r.startOffset;
	} else {
		r.setStart(sc,so);
	}
/*
		var sib = sc.previousSibling;
		while (sib) {
			if (sib.nodeName == "#text") { break; }
			sib = sib.previousSibling;
		}
		if (sib) { 
			sc = sib;
			so = sc.length;
		} else {
			so = 0;
			sok = 1;
		}
	}
*/
	eo = eo + 1;
	if (eo > ec.length) {
		r.setEndAfter(ec);
		ec = r.endContainer;
		eo = r.endOffset;
	} else {
		r.setEnd(ec,eo);
	}
/*
		var sib = ec.nextSibling;
		while (sib) {
			if (sib.nodeName == "#text") { break; }
			sib = sib.previousSibling;
		}
		if (sib) {
			ec = sib;
			eo = 0;
		} else {
			eo = ec.length;
			eok = 1;
		}
	}
*/
	var s = r.toString();
	if (s.match(/^\s*$/)) { return 0; }
	
	while( !start.test(s) ) {
		so = so - 1;
		if (so < 0) { 
			r.setStartBefore(sc);
			sc = r.startContainer;
			so = r.startOffset;
		} else {
			r.setStart(sc,so);
		}
		s = r.toString();
	}

		
					
		if (sc.previousSibling
	if (s>0) { s = s - 1; }
	if (e
						expandword(r);
						se.setRng(r);
					}
					if (se.isCollapsed()) {
						return;
					}
				}

				var value;
				value = se.getContent({format : 'text'});

				// optional filters needed here
				// verbatim, camelcase, stripspace, etc
				// trim (spaces, punct off ends)
				value = value.replace(/\s+/g,' ');
				value = value.replace(/\W+$/,'');
				value = value.replace(/^\W+/,'');

				ed.execCommand('mceBeginUndoLevel');
				// create new anchor element
				if (elm == null) {
					ed.execCommand('CreateLink', false, "#mce_temp_url#", {skip_undo : 1});

					elementArray = tinymce.grep(ed.dom.select("a"), function(n) { return ed.dom.getAttrib(n, 'href') == '#mce_temp_url#'; } );
					for (i=0; i<elementArray.length; i++) {
						elm = elementArray[i];
						ed.dom.setAttrib(elm,'href',value);
					}
				} else {
					ed.dom.setAttrib(elm,'href',value);
				}


				// Don't move caret if selection was image
				if (elm.childNodes.length != 1 || elm.firstChild.nodeName != 'IMG') {
					se.collapse(0);
				//	ed.focus();
				//	ed.selection.select(elm);
				//	ed.selection.collapse(0);
				//	ed.storeSelection();
				}

				ed.execCommand('mceEndUndoLevel');

			});

			// Register wikilink button
			ed.addButton('wikilink', {
				title : 'Wiki Link', //'wikilink.desc',
				cmd : 'mceWikilink',
				image : url + '/img/wikilink.gif'
			});

			//ed.addShortcut('ctrl+k', 'advlink.advlink_desc', 'mceAdvLink');

			// Add a node change handler, selects the button in the UI when a image is selected
			ed.onNodeChange.add(function(ed, cm, n, co) {
				//cm.setDisabled('wikilink', co && n.nodeName != 'A');
				cm.setActive('wikilink', n.nodeName == 'A' && !n.name);
				if (n.nodeName == 'A' && n.href) {
					cm.setDisabled('wikientry',0);
					cm.setActive('wikientry',1);
					//cm.get('wikientry').value(tinyMCE.activeEditor.dom.getAttrib(n,'href'));
					cm.get('wikientry').setAnchor(n);
				} else {
					cm.setDisabled('wikientry',1);
					cm.setActive('wikientry',0);
					//cm.get('wikientry').value('');
					cm.get('wikientry').setAnchor(null);
				}
			});
		},

		/**
		 * Creates control instances based in the incoming name. This method is normally not
		 * needed since the addButton method of the tinymce.Editor class is a more easy way of adding buttons
		 * but you sometimes need to create more complex controls like listboxes, split buttons etc then this
		 * method can be used to create those.
		 *
		 * @param {String} n Name of the control to create.
		 * @param {tinymce.ControlManager} cm Control manager to use inorder to create new control.
		 * @return {tinymce.ui.Control} New control instance or null if no control was created.
		 */
		createControl : function(n, cm) {
			var t = this, ed = t.editor;
			if (n != 'wikientry') {
				return null;
			}

			var c = cm.createEntry(n,{});
			return c;
		},

		/**
		 * Returns information about the plugin as a name/value array.
		 * The current keys are longname, author, authorurl, infourl and version.
		 *
		 * @return {Object} Name/value array containing information about the plugin.
		 */
		getInfo : function() {
			return {
				longname : 'Wikilink plugin',
				author : 'John Williams',
				authorurl : 'http://swank.m3th.org/',
				infourl : 'http://swank.m3th.org/wikilink',
				version : "0.2"
			};
		}
	});

	Object.extend( tinymce.ControlManager.prototype, {  createEntry : function(id,s,cc) {
		var t = this, ed = t.editor;

		if (t.get(id)) return null;

		s.scope = ed;
		// s.onchange

		id = t.prefix + id;

		c = new tinymce.ui.Entry(id,s);

		t.controls[id] = c;
		return t.add(c);
	}});

	tinymce.create('tinymce.ui.Entry:tinymce.ui.Control', {
		Entry : function(id, s) {
			var t = this;

			t.parent(id,s);
			t.classPrefix = 'mceEntry';
                        //t.onChange = new tinymce.util.Dispatcher(t);
                        t.onPostRender = new tinymce.util.Dispatcher(t);
                        //t.onAdd = new tinymce.util.Dispatcher(t);
			t.onRenderMenu = new tinymce.util.Dispatcher(t);
		},

		renderHTML : function() {
			var h, t = this;
			var DOM = tinymce.DOM;
// needs added to ui.css
//.defaultSkin input {background:#fff;border:1px solid #808080;font-size:10px;padding-top:1px;padding-bottom:1px;'}

			h = DOM.createHTML('input', { id : t.id, type : 'text', value : '', style : 'background:#fff;border:1px solid #808080;font-size:10px;padding-top:1px;padding-bottom:1px;' });
			return h;
		},

		postRender : function() {
			var t = this, s = t.settings;
			tinymce.dom.Event.add(t.id, 'focus', function(e) {
				if (!t.anchor) { this.blur; }
				tinyMCE.activeEditor.selection.select(t.anchor);
			});
			tinymce.dom.Event.add(t.id, 'blur', function(e) {
				tinyMCE.activeEditor.dom.setAttrib(t.anchor,'href',t.value());
			})
		},

		setDisabled : function(s) {
			tinymce.DOM.get(this.id).disabled = s;
		},

		isDisabled : function() {
			return tinymce.DOM.get(this.id).disabled;
		},

		setAnchor : function(n) {
			this.anchor = n;
			if (n != null) {
				this.value(tinyMCE.activeEditor.dom.getAttrib(n,'href'));
			} else {
				this.value('');
			}
		},

		value : function(v) {
			var c = tinymce.DOM.get(this.id);
			if (v != null) {
				c.value = v;
			}
			return c.value;
		},
	});

	// Register plugin
	tinymce.PluginManager.add('wikilink', tinymce.plugins.WikilinkPlugin);
})();


