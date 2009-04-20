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
				// Wish this worked in firefox...
				if (!elm && se.isCollapsed()) {
					var r = se.getRng();
					if (tinymce.isIE) {
						r.expand('word');
						se.setRng(r);
					} else if (tinymce.isGecko) {
						rangehack.expand(r);
						se.setRng(r);
					}
					if (se.isCollapsed()) {
						return;
					}
				}

				var value;
				if (elm) {
					value = elm.text;
				} else {
					value = se.getContent({format : 'text'});
				}

				// optional filters here
				var opt = ed.getParam('wikilink_style','trim');

				// Verbatim: disable all filters

				// StripNonWord: remove all punctuation
				if (opt.match(/\bstripnonword\b/i)) {
					value = value.replace(/\W+/g,' ');
				}

				// Trim: remove beg/end punct and excess spaces
				if (opt.match(/\btrim\b/i)) {
					value = value.replace(/\s+/g,' ');
					value = value.replace(/\W+$/,'');
					value = value.replace(/^\W+/,'');
				}

				// LowerCase: convert to lower case
				if (opt.match(/\blowercase\b/i)) {
					value = value.toLowerCase();
				}

				// CamelCase: do CamelCaseConversion
				if (opt.match(/\bcamelcase\b/i)) {
					value = value.replace( /(?:^|\s+)(\S)/g,
					function(m,s){return s.toUpperCase();}
					);
				}

				// StripSpace: remove all spaces
				if (opt.match(/\bstripspace\b/i)) {
					value = value.replace(/\s+/g,'');
				}

				// do nothing if no href value
				if (!value || !value.match(/\S/)) {
					return;
				}

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
					// IE does not put caret inside elm
					se.select(elm.childNodes[elm.childNodes.length-1]);
					se.collapse(0);
				}

				ed.execCommand('mceEndUndoLevel');

			});

			// Register wikilink button
			ed.addButton('wikilink', {
				title : 'Wiki Link', //'wikilink.desc',
				cmd : 'mceWikilink',
				image : url + '/img/wikilink.gif'
			});

			// zero-click link
			ed.addShortcut('ctrl+l', 'Wiki Link', 'mceWikilink');

			// node change handler, 
			// activates button and when in link or selection
			// set anchor for entry when in link
			ed.onNodeChange.add(function(ed, cm, n, co) {
				var a = ed.dom.getParent(n,'A');
				var we = cm.get('wikientry');
				if (a && a.href) {
					cm.setDisabled('wikilink',0);
					cm.setActive('wikilink',1);
					cm.setDisabled('wikientry',0);
					cm.setActive('wikientry',1);
					if (we) { we.setAnchor(a); }
				} else if (!co) {
					cm.setDisabled('wikilink',0);
					cm.setActive('wikilink',0);
					cm.setDisabled('wikientry',1);
					cm.setActive('wikientry',0);
					if (we) { we.setAnchor(null); }
				} else {
					cm.setDisabled('wikilink',0);
					cm.setActive('wikilink',0);
					cm.setDisabled('wikientry',1);
					cm.setActive('wikientry',0);
					if (we) { we.setAnchor(null); }
				}
			});
		},

		/**
		 * Creates the wikientry text box
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
				version : "0.6"
			};
		}
	});

	/* Extend the ControlManager to support the Entry widget below */
	tinymce.extend( tinymce.ControlManager.prototype, {  
	    createEntry : function(id,s,cc) {
		var t = this, ed = t.editor;

		if (t.get(id)) return null;

		s.scope = ed;
		// s.onchange

		id = t.prefix + id;

		c = new tinymce.ui.Entry(id,s);

		t.controls[id] = c;
		return t.add(c);
	    }
	});

	/* The text entry widget.
	 * TinyMCE does not have one of these yet, unfortunately.
	 * Ideally this would be more generic, and I would only need 
	 * to override a few things, such as onFocus, onBlur, and setAnchor
	 */
	tinymce.create('tinymce.ui.Entry:tinymce.ui.Control', {
		Entry : function(id, s) {
			var t = this;

			t.parent(id,s);
			t.classPrefix = 'mceEntry';
			t.onRenderMenu = new tinymce.util.Dispatcher(t);
                        t.onPostRender = new tinymce.util.Dispatcher(t);
		},

		renderHTML : function() {
			var h, t = this;
			var DOM = tinymce.DOM;
// style needs added to ui.css
// .defaultSkin input.mceEntry {...}
			h = DOM.createHTML('input', { id : t.id, type : 'text', value : '', 'class' : t.classPrefix, style : 'background:#fff;border:1px solid #ccc;font-size:11px;padding:1px;margin:1px;' });
			return h;
		},

		postRender : function() {
			var t = this, s = t.settings;
			tinymce.dom.Event.add(t.id, 'focus', function(e) {
				if (!t.anchor) { this.blur; }
				//tinyMCE.activeEditor.selection.select(t.anchor);
			});
			tinymce.dom.Event.add(t.id, 'blur', function(e) {
				var ed = tinyMCE.activeEditor;
				var a = t.oldanchor;
				t.oldanchor = null;
				var then = ed.dom.getAttrib(a,'href');
				var now = t.value();
				if (then == now) { return; }
				if (now) {
					ed.execCommand('mceBeginUndoLevel');
					ed.dom.setAttrib(a,'href',now);
					ed.execCommand('mceEndUndoLevel');
				} else {
					ed.execCommand('mceBeginUndoLevel');
					var i = ed.selection.getBookmark();
					ed.dom.remove(a,1);
					ed.selection.moveToBookmark(i);
					ed.execCommand('mceEndUndoLevel');
				}
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
				this.oldanchor = n;
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
		}
	});

	// Register plugin
	tinymce.PluginManager.add('wikilink', tinymce.plugins.WikilinkPlugin);
})();

rangehack = {
	skipNonBreak : { acceptNode: function(n) { 
		if (n.nodeName.match(/^(a|b|basefont|big|em|font|i|s|small|span|strike|strong|sub|sup|tt|u|del|ins)$/i)) {
			return NodeFilter.FILTER_SKIP;
		}
		// block level tags should always be a wordbreak
		// the treewalker thing will stop on any non-text node
		return NodeFilter.FILTER_ACCEPT; 
	} },

	decStart: function (r) {
		if (r.startOffset > 0) {
			r.setStart(r.startContainer,r.startOffset-1);
			return r;
		} else {
			this.tw.currentNode = r.startContainer;
			var nn = this.tw.previousSibling();
			if (nn == null || nn.nodeName != '#text') { return null; }
			r.setStart(nn,nn.length);
			return r;
		}
	},

	incEnd: function (r) {
		len = r.endContainer.length;
		if (r.endOffset < len) {
			r.setEnd(r.endContainer,r.endOffset+1);
			return r;
		} else {
			this.tw.currentNode = r.endContainer;
			var nn = this.tw.nextSibling();
			if (nn == null || nn.nodeName != '#text') { return null; }
			r.setEnd(nn,0);
			return r;
		}
	},

	expand: function (ser) {
	  if (ser.startContainer.nodeName != '#text') { return; }
	  var r = ser.cloneRange();
	  r.collapse(1);

	  var isbeg = 0, isend = 0;
	  var x;
	  this.tw = document.createTreeWalker(document.body,
		(NodeFilter.SHOW_TEXT+NodeFilter.SHOW_ELEMENT),this.skipNonBreak,false);

	  do {
		if (!isbeg) {
			var n = r.cloneRange();
			n.collapse(1);
			if (this.decStart(n) && !n.toString().match(/\s/)) {
				r.setStart(n.startContainer,n.startOffset);
			} else {
				isbeg = 1;
			}
			n.detach();
		}
		if (!isend) {
			var n = r.cloneRange();
			n.collapse(0);
			if (this.incEnd(n) && !n.toString().match(/\s/)) {
				r.setEnd(n.endContainer,n.endOffset);
			} else {
				isend = 1;
			}
			n.detach;
		}
		x = r.toString();
	  } while (!isbeg || !isend);

	  ser.setStart(r.startContainer,r.startOffset);
	  ser.setEnd(r.endContainer,r.endOffset);
	}
};


