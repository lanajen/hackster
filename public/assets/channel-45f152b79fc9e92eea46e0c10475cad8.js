/**
 * marked - a markdown parser
 * Copyright (c) 2011-2014, Christopher Jeffrey. (MIT Licensed)
 * https://github.com/chjj/marked
 */

(function(){var block={newline:/^\n+/,code:/^( {4}[^\n]+\n*)+/,fences:noop,hr:/^( *[-*_]){3,} *(?:\n+|$)/,heading:/^ *(#{1,6}) *([^\n]+?) *#* *(?:\n+|$)/,nptable:noop,lheading:/^([^\n]+)\n *(=|-){2,} *(?:\n+|$)/,blockquote:/^( *>[^\n]+(\n(?!def)[^\n]+)*\n*)+/,list:/^( *)(bull) [\s\S]+?(?:hr|def|\n{2,}(?! )(?!\1bull )\n*|\s*$)/,html:/^ *(?:comment|closed|closing) *(?:\n{2,}|\s*$)/,def:/^ *\[([^\]]+)\]: *<?([^\s>]+)>?(?: +["(]([^\n]+)[")])? *(?:\n+|$)/,table:noop,paragraph:/^((?:[^\n]+\n?(?!hr|heading|lheading|blockquote|tag|def))+)\n*/,text:/^[^\n]+/};block.bullet=/(?:[*+-]|\d+\.)/;block.item=/^( *)(bull) [^\n]*(?:\n(?!\1bull )[^\n]*)*/;block.item=replace(block.item,"gm")(/bull/g,block.bullet)();block.list=replace(block.list)(/bull/g,block.bullet)("hr","\\n+(?=\\1?(?:[-*_] *){3,}(?:\\n+|$))")("def","\\n+(?="+block.def.source+")")();block.blockquote=replace(block.blockquote)("def",block.def)();block._tag="(?!(?:"+"a|em|strong|small|s|cite|q|dfn|abbr|data|time|code"+"|var|samp|kbd|sub|sup|i|b|u|mark|ruby|rt|rp|bdi|bdo"+"|span|br|wbr|ins|del|img)\\b)\\w+(?!:/|[^\\w\\s@]*@)\\b";block.html=replace(block.html)("comment",/<!--[\s\S]*?-->/)("closed",/<(tag)[\s\S]+?<\/\1>/)("closing",/<tag(?:"[^"]*"|'[^']*'|[^'">])*?>/)(/tag/g,block._tag)();block.paragraph=replace(block.paragraph)("hr",block.hr)("heading",block.heading)("lheading",block.lheading)("blockquote",block.blockquote)("tag","<"+block._tag)("def",block.def)();block.normal=merge({},block);block.gfm=merge({},block.normal,{fences:/^ *(`{3,}|~{3,}) *(\S+)? *\n([\s\S]+?)\s*\1 *(?:\n+|$)/,paragraph:/^/});block.gfm.paragraph=replace(block.paragraph)("(?!","(?!"+block.gfm.fences.source.replace("\\1","\\2")+"|"+block.list.source.replace("\\1","\\3")+"|")();block.tables=merge({},block.gfm,{nptable:/^ *(\S.*\|.*)\n *([-:]+ *\|[-| :]*)\n((?:.*\|.*(?:\n|$))*)\n*/,table:/^ *\|(.+)\n *\|( *[-:]+[-| :]*)\n((?: *\|.*(?:\n|$))*)\n*/});function Lexer(options){this.tokens=[];this.tokens.links={};this.options=options||marked.defaults;this.rules=block.normal;if(this.options.gfm){if(this.options.tables){this.rules=block.tables}else{this.rules=block.gfm}}}Lexer.rules=block;Lexer.lex=function(src,options){var lexer=new Lexer(options);return lexer.lex(src)};Lexer.prototype.lex=function(src){src=src.replace(/\r\n|\r/g,"\n").replace(/\t/g,"    ").replace(/\u00a0/g," ").replace(/\u2424/g,"\n");return this.token(src,true)};Lexer.prototype.token=function(src,top,bq){var src=src.replace(/^ +$/gm,""),next,loose,cap,bull,b,item,space,i,l;while(src){if(cap=this.rules.newline.exec(src)){src=src.substring(cap[0].length);if(cap[0].length>1){this.tokens.push({type:"space"})}}if(cap=this.rules.code.exec(src)){src=src.substring(cap[0].length);cap=cap[0].replace(/^ {4}/gm,"");this.tokens.push({type:"code",text:!this.options.pedantic?cap.replace(/\n+$/,""):cap});continue}if(cap=this.rules.fences.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"code",lang:cap[2],text:cap[3]});continue}if(cap=this.rules.heading.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"heading",depth:cap[1].length,text:cap[2]});continue}if(top&&(cap=this.rules.nptable.exec(src))){src=src.substring(cap[0].length);item={type:"table",header:cap[1].replace(/^ *| *\| *$/g,"").split(/ *\| */),align:cap[2].replace(/^ *|\| *$/g,"").split(/ *\| */),cells:cap[3].replace(/\n$/,"").split("\n")};for(i=0;i<item.align.length;i++){if(/^ *-+: *$/.test(item.align[i])){item.align[i]="right"}else if(/^ *:-+: *$/.test(item.align[i])){item.align[i]="center"}else if(/^ *:-+ *$/.test(item.align[i])){item.align[i]="left"}else{item.align[i]=null}}for(i=0;i<item.cells.length;i++){item.cells[i]=item.cells[i].split(/ *\| */)}this.tokens.push(item);continue}if(cap=this.rules.lheading.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"heading",depth:cap[2]==="="?1:2,text:cap[1]});continue}if(cap=this.rules.hr.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"hr"});continue}if(cap=this.rules.blockquote.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"blockquote_start"});cap=cap[0].replace(/^ *> ?/gm,"");this.token(cap,top,true);this.tokens.push({type:"blockquote_end"});continue}if(cap=this.rules.list.exec(src)){src=src.substring(cap[0].length);bull=cap[2];this.tokens.push({type:"list_start",ordered:bull.length>1});cap=cap[0].match(this.rules.item);next=false;l=cap.length;i=0;for(;i<l;i++){item=cap[i];space=item.length;item=item.replace(/^ *([*+-]|\d+\.) +/,"");if(~item.indexOf("\n ")){space-=item.length;item=!this.options.pedantic?item.replace(new RegExp("^ {1,"+space+"}","gm"),""):item.replace(/^ {1,4}/gm,"")}if(this.options.smartLists&&i!==l-1){b=block.bullet.exec(cap[i+1])[0];if(bull!==b&&!(bull.length>1&&b.length>1)){src=cap.slice(i+1).join("\n")+src;i=l-1}}loose=next||/\n\n(?!\s*$)/.test(item);if(i!==l-1){next=item.charAt(item.length-1)==="\n";if(!loose)loose=next}this.tokens.push({type:loose?"loose_item_start":"list_item_start"});this.token(item,false,bq);this.tokens.push({type:"list_item_end"})}this.tokens.push({type:"list_end"});continue}if(cap=this.rules.html.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:this.options.sanitize?"paragraph":"html",pre:cap[1]==="pre"||cap[1]==="script"||cap[1]==="style",text:cap[0]});continue}if(!bq&&top&&(cap=this.rules.def.exec(src))){src=src.substring(cap[0].length);this.tokens.links[cap[1].toLowerCase()]={href:cap[2],title:cap[3]};continue}if(top&&(cap=this.rules.table.exec(src))){src=src.substring(cap[0].length);item={type:"table",header:cap[1].replace(/^ *| *\| *$/g,"").split(/ *\| */),align:cap[2].replace(/^ *|\| *$/g,"").split(/ *\| */),cells:cap[3].replace(/(?: *\| *)?\n$/,"").split("\n")};for(i=0;i<item.align.length;i++){if(/^ *-+: *$/.test(item.align[i])){item.align[i]="right"}else if(/^ *:-+: *$/.test(item.align[i])){item.align[i]="center"}else if(/^ *:-+ *$/.test(item.align[i])){item.align[i]="left"}else{item.align[i]=null}}for(i=0;i<item.cells.length;i++){item.cells[i]=item.cells[i].replace(/^ *\| *| *\| *$/g,"").split(/ *\| */)}this.tokens.push(item);continue}if(top&&(cap=this.rules.paragraph.exec(src))){src=src.substring(cap[0].length);this.tokens.push({type:"paragraph",text:cap[1].charAt(cap[1].length-1)==="\n"?cap[1].slice(0,-1):cap[1]});continue}if(cap=this.rules.text.exec(src)){src=src.substring(cap[0].length);this.tokens.push({type:"text",text:cap[0]});continue}if(src){throw new Error("Infinite loop on byte: "+src.charCodeAt(0))}}return this.tokens};var inline={escape:/^\\([\\`*{}\[\]()#+\-.!_>])/,autolink:/^<([^ >]+(@|:\/)[^ >]+)>/,url:noop,tag:/^<!--[\s\S]*?-->|^<\/?\w+(?:"[^"]*"|'[^']*'|[^'">])*?>/,link:/^!?\[(inside)\]\(href\)/,reflink:/^!?\[(inside)\]\s*\[([^\]]*)\]/,nolink:/^!?\[((?:\[[^\]]*\]|[^\[\]])*)\]/,strong:/^__([\s\S]+?)__(?!_)|^\*\*([\s\S]+?)\*\*(?!\*)/,em:/^\b_((?:__|[\s\S])+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,code:/^(`+)\s*([\s\S]*?[^`])\s*\1(?!`)/,br:/^ {2,}\n(?!\s*$)/,del:noop,text:/^[\s\S]+?(?=[\\<!\[_*`]| {2,}\n|$)/};inline._inside=/(?:\[[^\]]*\]|[^\[\]]|\](?=[^\[]*\]))*/;inline._href=/\s*<?([\s\S]*?)>?(?:\s+['"]([\s\S]*?)['"])?\s*/;inline.link=replace(inline.link)("inside",inline._inside)("href",inline._href)();inline.reflink=replace(inline.reflink)("inside",inline._inside)();inline.normal=merge({},inline);inline.pedantic=merge({},inline.normal,{strong:/^__(?=\S)([\s\S]*?\S)__(?!_)|^\*\*(?=\S)([\s\S]*?\S)\*\*(?!\*)/,em:/^_(?=\S)([\s\S]*?\S)_(?!_)|^\*(?=\S)([\s\S]*?\S)\*(?!\*)/});inline.gfm=merge({},inline.normal,{escape:replace(inline.escape)("])","~|])")(),url:/^(https?:\/\/[^\s<]+[^<.,:;"')\]\s])/,del:/^~~(?=\S)([\s\S]*?\S)~~/,text:replace(inline.text)("]|","~]|")("|","|https?://|")()});inline.breaks=merge({},inline.gfm,{br:replace(inline.br)("{2,}","*")(),text:replace(inline.gfm.text)("{2,}","*")()});function InlineLexer(links,options){this.options=options||marked.defaults;this.links=links;this.rules=inline.normal;this.renderer=this.options.renderer||new Renderer;this.renderer.options=this.options;if(!this.links){throw new Error("Tokens array requires a `links` property.")}if(this.options.gfm){if(this.options.breaks){this.rules=inline.breaks}else{this.rules=inline.gfm}}else if(this.options.pedantic){this.rules=inline.pedantic}}InlineLexer.rules=inline;InlineLexer.output=function(src,links,options){var inline=new InlineLexer(links,options);return inline.output(src)};InlineLexer.prototype.output=function(src){var out="",link,text,href,cap;while(src){if(cap=this.rules.escape.exec(src)){src=src.substring(cap[0].length);out+=cap[1];continue}if(cap=this.rules.autolink.exec(src)){src=src.substring(cap[0].length);if(cap[2]==="@"){text=cap[1].charAt(6)===":"?this.mangle(cap[1].substring(7)):this.mangle(cap[1]);href=this.mangle("mailto:")+text}else{text=escape(cap[1]);href=text}out+=this.renderer.link(href,null,text);continue}if(!this.inLink&&(cap=this.rules.url.exec(src))){src=src.substring(cap[0].length);text=escape(cap[1]);href=text;out+=this.renderer.link(href,null,text);continue}if(cap=this.rules.tag.exec(src)){if(!this.inLink&&/^<a /i.test(cap[0])){this.inLink=true}else if(this.inLink&&/^<\/a>/i.test(cap[0])){this.inLink=false}src=src.substring(cap[0].length);out+=this.options.sanitize?escape(cap[0]):cap[0];continue}if(cap=this.rules.link.exec(src)){src=src.substring(cap[0].length);this.inLink=true;out+=this.outputLink(cap,{href:cap[2],title:cap[3]});this.inLink=false;continue}if((cap=this.rules.reflink.exec(src))||(cap=this.rules.nolink.exec(src))){src=src.substring(cap[0].length);link=(cap[2]||cap[1]).replace(/\s+/g," ");link=this.links[link.toLowerCase()];if(!link||!link.href){out+=cap[0].charAt(0);src=cap[0].substring(1)+src;continue}this.inLink=true;out+=this.outputLink(cap,link);this.inLink=false;continue}if(cap=this.rules.strong.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.strong(this.output(cap[2]||cap[1]));continue}if(cap=this.rules.em.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.em(this.output(cap[2]||cap[1]));continue}if(cap=this.rules.code.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.codespan(escape(cap[2],true));continue}if(cap=this.rules.br.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.br();continue}if(cap=this.rules.del.exec(src)){src=src.substring(cap[0].length);out+=this.renderer.del(this.output(cap[1]));continue}if(cap=this.rules.text.exec(src)){src=src.substring(cap[0].length);out+=escape(this.smartypants(cap[0]));continue}if(src){throw new Error("Infinite loop on byte: "+src.charCodeAt(0))}}return out};InlineLexer.prototype.outputLink=function(cap,link){var href=escape(link.href),title=link.title?escape(link.title):null;return cap[0].charAt(0)!=="!"?this.renderer.link(href,title,this.output(cap[1])):this.renderer.image(href,title,escape(cap[1]))};InlineLexer.prototype.smartypants=function(text){if(!this.options.smartypants)return text;return text.replace(/--/g,"—").replace(/(^|[-\u2014/(\[{"\s])'/g,"$1‘").replace(/'/g,"’").replace(/(^|[-\u2014/(\[{\u2018\s])"/g,"$1“").replace(/"/g,"”").replace(/\.{3}/g,"…")};InlineLexer.prototype.mangle=function(text){var out="",l=text.length,i=0,ch;for(;i<l;i++){ch=text.charCodeAt(i);if(Math.random()>.5){ch="x"+ch.toString(16)}out+="&#"+ch+";"}return out};function Renderer(options){this.options=options||{}}Renderer.prototype.code=function(code,lang,escaped){if(this.options.highlight){var out=this.options.highlight(code,lang);if(out!=null&&out!==code){escaped=true;code=out}}if(!lang){return"<pre><code>"+(escaped?code:escape(code,true))+"\n</code></pre>"}return'<pre><code class="'+this.options.langPrefix+escape(lang,true)+'">'+(escaped?code:escape(code,true))+"\n</code></pre>\n"};Renderer.prototype.blockquote=function(quote){return"<blockquote>\n"+quote+"</blockquote>\n"};Renderer.prototype.html=function(html){return html};Renderer.prototype.heading=function(text,level,raw){return"<h"+level+' id="'+this.options.headerPrefix+raw.toLowerCase().replace(/[^\w]+/g,"-")+'">'+text+"</h"+level+">\n"};Renderer.prototype.hr=function(){return this.options.xhtml?"<hr/>\n":"<hr>\n"};Renderer.prototype.list=function(body,ordered){var type=ordered?"ol":"ul";return"<"+type+">\n"+body+"</"+type+">\n"};Renderer.prototype.listitem=function(text){return"<li>"+text+"</li>\n"};Renderer.prototype.paragraph=function(text){return"<p>"+text+"</p>\n"};Renderer.prototype.table=function(header,body){return"<table>\n"+"<thead>\n"+header+"</thead>\n"+"<tbody>\n"+body+"</tbody>\n"+"</table>\n"};Renderer.prototype.tablerow=function(content){return"<tr>\n"+content+"</tr>\n"};Renderer.prototype.tablecell=function(content,flags){var type=flags.header?"th":"td";var tag=flags.align?"<"+type+' style="text-align:'+flags.align+'">':"<"+type+">";return tag+content+"</"+type+">\n"};Renderer.prototype.strong=function(text){return"<strong>"+text+"</strong>"};Renderer.prototype.em=function(text){return"<em>"+text+"</em>"};Renderer.prototype.codespan=function(text){return"<code>"+text+"</code>"};Renderer.prototype.br=function(){return this.options.xhtml?"<br/>":"<br>"};Renderer.prototype.del=function(text){return"<del>"+text+"</del>"};Renderer.prototype.link=function(href,title,text){if(this.options.sanitize){try{var prot=decodeURIComponent(unescape(href)).replace(/[^\w:]/g,"").toLowerCase()}catch(e){return""}if(prot.indexOf("javascript:")===0){return""}}var out='<a href="'+href+'"';if(title){out+=' title="'+title+'"'}out+=">"+text+"</a>";return out};Renderer.prototype.image=function(href,title,text){var out='<img src="'+href+'" alt="'+text+'"';if(title){out+=' title="'+title+'"'}out+=this.options.xhtml?"/>":">";return out};function Parser(options){this.tokens=[];this.token=null;this.options=options||marked.defaults;this.options.renderer=this.options.renderer||new Renderer;this.renderer=this.options.renderer;this.renderer.options=this.options}Parser.parse=function(src,options,renderer){var parser=new Parser(options,renderer);return parser.parse(src)};Parser.prototype.parse=function(src){this.inline=new InlineLexer(src.links,this.options,this.renderer);this.tokens=src.reverse();var out="";while(this.next()){out+=this.tok()}return out};Parser.prototype.next=function(){return this.token=this.tokens.pop()};Parser.prototype.peek=function(){return this.tokens[this.tokens.length-1]||0};Parser.prototype.parseText=function(){var body=this.token.text;while(this.peek().type==="text"){body+="\n"+this.next().text}return this.inline.output(body)};Parser.prototype.tok=function(){switch(this.token.type){case"space":{return""}case"hr":{return this.renderer.hr()}case"heading":{return this.renderer.heading(this.inline.output(this.token.text),this.token.depth,this.token.text)}case"code":{return this.renderer.code(this.token.text,this.token.lang,this.token.escaped)}case"table":{var header="",body="",i,row,cell,flags,j;cell="";for(i=0;i<this.token.header.length;i++){flags={header:true,align:this.token.align[i]};cell+=this.renderer.tablecell(this.inline.output(this.token.header[i]),{header:true,align:this.token.align[i]})}header+=this.renderer.tablerow(cell);for(i=0;i<this.token.cells.length;i++){row=this.token.cells[i];cell="";for(j=0;j<row.length;j++){cell+=this.renderer.tablecell(this.inline.output(row[j]),{header:false,align:this.token.align[j]})}body+=this.renderer.tablerow(cell)}return this.renderer.table(header,body)}case"blockquote_start":{var body="";while(this.next().type!=="blockquote_end"){body+=this.tok()}return this.renderer.blockquote(body)}case"list_start":{var body="",ordered=this.token.ordered;while(this.next().type!=="list_end"){body+=this.tok()}return this.renderer.list(body,ordered)}case"list_item_start":{var body="";while(this.next().type!=="list_item_end"){body+=this.token.type==="text"?this.parseText():this.tok()}return this.renderer.listitem(body)}case"loose_item_start":{var body="";while(this.next().type!=="list_item_end"){body+=this.tok()}return this.renderer.listitem(body)}case"html":{var html=!this.token.pre&&!this.options.pedantic?this.inline.output(this.token.text):this.token.text;return this.renderer.html(html)}case"paragraph":{return this.renderer.paragraph(this.inline.output(this.token.text))}case"text":{return this.renderer.paragraph(this.parseText())}}};function escape(html,encode){return html.replace(!encode?/&(?!#?\w+;)/g:/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;")}function unescape(html){return html.replace(/&([#\w]+);/g,function(_,n){n=n.toLowerCase();if(n==="colon")return":";if(n.charAt(0)==="#"){return n.charAt(1)==="x"?String.fromCharCode(parseInt(n.substring(2),16)):String.fromCharCode(+n.substring(1))}return""})}function replace(regex,opt){regex=regex.source;opt=opt||"";return function self(name,val){if(!name)return new RegExp(regex,opt);val=val.source||val;val=val.replace(/(^|[^\[])\^/g,"$1");regex=regex.replace(name,val);return self}}function noop(){}noop.exec=noop;function merge(obj){var i=1,target,key;for(;i<arguments.length;i++){target=arguments[i];for(key in target){if(Object.prototype.hasOwnProperty.call(target,key)){obj[key]=target[key]}}}return obj}function marked(src,opt,callback){if(callback||typeof opt==="function"){if(!callback){callback=opt;opt=null}opt=merge({},marked.defaults,opt||{});var highlight=opt.highlight,tokens,pending,i=0;try{tokens=Lexer.lex(src,opt)}catch(e){return callback(e)}pending=tokens.length;var done=function(err){if(err){opt.highlight=highlight;return callback(err)}var out;try{out=Parser.parse(tokens,opt)}catch(e){err=e}opt.highlight=highlight;return err?callback(err):callback(null,out)};if(!highlight||highlight.length<3){return done()}delete opt.highlight;if(!pending)return done();for(;i<tokens.length;i++){(function(token){if(token.type!=="code"){return--pending||done()}return highlight(token.text,token.lang,function(err,code){if(err)return done(err);if(code==null||code===token.text){return--pending||done()}token.text=code;token.escaped=true;--pending||done()})})(tokens[i])}return}try{if(opt)opt=merge({},marked.defaults,opt);return Parser.parse(Lexer.lex(src,opt),opt)}catch(e){e.message+="\nPlease report this to https://github.com/chjj/marked.";if((opt||marked.defaults).silent){return"<p>An error occured:</p><pre>"+escape(e.message+"",true)+"</pre>"}throw e}}marked.options=marked.setOptions=function(opt){merge(marked.defaults,opt);return marked};marked.defaults={gfm:true,tables:true,breaks:false,pedantic:false,sanitize:false,smartLists:false,silent:false,highlight:null,langPrefix:"lang-",smartypants:false,headerPrefix:"",renderer:new Renderer,xhtml:false};marked.Parser=Parser;marked.parser=Parser.parse;marked.Renderer=Renderer;marked.Lexer=Lexer;marked.lexer=Lexer.lex;marked.InlineLexer=InlineLexer;marked.inlineLexer=InlineLexer.output;marked.parse=marked;if(typeof module!=="undefined"&&typeof exports==="object"){module.exports=marked}else if(typeof define==="function"&&define.amd){define(function(){return marked})}else{this.marked=marked}}).call(function(){return this||(typeof window!=="undefined"?window:global)}());
!function(t,e){"object"==typeof exports&&"object"==typeof module?module.exports=e(require("react")):"function"==typeof define&&define.amd?define(["react"],e):"object"==typeof exports?exports.ReactRouter=e(require("react")):t.ReactRouter=e(t.React)}(this,function(t){return function(t){function e(r){if(n[r])return n[r].exports;var o=n[r]={exports:{},id:r,loaded:!1};return t[r].call(o.exports,o,o.exports,e),o.loaded=!0,o.exports}var n={};return e.m=t,e.c=n,e.p="",e(0)}([function(t,e,n){"use strict";e.DefaultRoute=n(1),e.Link=n(2),e.NotFoundRoute=n(3),e.Redirect=n(4),e.Route=n(5),e.RouteHandler=n(6),e.HashLocation=n(7),e.HistoryLocation=n(8),e.RefreshLocation=n(9),e.StaticLocation=n(10),e.TestLocation=n(11),e.ImitateBrowserBehavior=n(12),e.ScrollToTopBehavior=n(13),e.History=n(14),e.Navigation=n(15),e.State=n(16),e.createRoute=n(17).createRoute,e.createDefaultRoute=n(17).createDefaultRoute,e.createNotFoundRoute=n(17).createNotFoundRoute,e.createRedirect=n(17).createRedirect,e.createRoutesFromReactChildren=n(18),e.create=n(19),e.run=n(20)},function(t,e,n){"use strict";var r=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},o=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},i=n(22),a=n(6),u=n(5),s=function(t){function e(){o(this,e),null!=t&&t.apply(this,arguments)}return r(e,t),e}(u);s.propTypes={name:i.string,path:i.falsy,children:i.falsy,handler:i.func.isRequired},s.defaultProps={handler:a},t.exports=s},function(t,e,n){"use strict";function r(t){return 0===t.button}function o(t){return!!(t.metaKey||t.altKey||t.ctrlKey||t.shiftKey)}var i=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),a=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},u=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},s=n(21),c=n(33),f=n(22),l=function(t){function e(){u(this,e),null!=t&&t.apply(this,arguments)}return a(e,t),i(e,{handleClick:{value:function(t){var e,n=!0;this.props.onClick&&(e=this.props.onClick(t)),!o(t)&&r(t)&&((e===!1||t.defaultPrevented===!0)&&(n=!1),t.preventDefault(),n&&this.context.router.transitionTo(this.props.to,this.props.params,this.props.query))}},getHref:{value:function(){return this.context.router.makeHref(this.props.to,this.props.params,this.props.query)}},getClassName:{value:function(){var t=this.props.className;return this.getActiveState()&&(t+=" "+this.props.activeClassName),t}},getActiveState:{value:function(){return this.context.router.isActive(this.props.to,this.props.params,this.props.query)}},render:{value:function(){var t=c({},this.props,{href:this.getHref(),className:this.getClassName(),onClick:this.handleClick.bind(this)});return t.activeStyle&&this.getActiveState()&&(t.style=t.activeStyle),s.DOM.a(t,this.props.children)}}}),e}(s.Component);l.contextTypes={router:f.router.isRequired},l.propTypes={activeClassName:f.string.isRequired,to:f.oneOfType([f.string,f.route]).isRequired,params:f.object,query:f.object,activeStyle:f.object,onClick:f.func},l.defaultProps={activeClassName:"active",className:""},t.exports=l},function(t,e,n){"use strict";var r=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},o=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},i=n(22),a=n(6),u=n(5),s=function(t){function e(){o(this,e),null!=t&&t.apply(this,arguments)}return r(e,t),e}(u);s.propTypes={name:i.string,path:i.falsy,children:i.falsy,handler:i.func.isRequired},s.defaultProps={handler:a},t.exports=s},function(t,e,n){"use strict";var r=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},o=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},i=n(22),a=n(5),u=function(t){function e(){o(this,e),null!=t&&t.apply(this,arguments)}return r(e,t),e}(a);u.propTypes={path:i.string,from:i.string,to:i.string,handler:i.falsy},u.defaultProps={},t.exports=u},function(t,e,n){"use strict";var r=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),o=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},i=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},a=n(21),u=n(34),s=n(22),c=n(6),f=function(t){function e(){i(this,e),null!=t&&t.apply(this,arguments)}return o(e,t),r(e,{render:{value:function(){u(!1,"%s elements are for router configuration only and should not be rendered",this.constructor.name)}}}),e}(a.Component);f.propTypes={name:s.string,path:s.string,handler:s.func,ignoreScrollBehavior:s.bool},f.defaultProps={handler:c},t.exports=f},function(t,e,n){"use strict";var r=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),o=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},i=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},a=n(21),u=n(23),s=n(33),c=n(22),f="__routeHandler__",l=function(t){function e(){i(this,e),null!=t&&t.apply(this,arguments)}return o(e,t),r(e,{getChildContext:{value:function(){return{routeDepth:this.context.routeDepth+1}}},componentDidMount:{value:function(){this._updateRouteComponent(this.refs[f])}},componentDidUpdate:{value:function(){this._updateRouteComponent(this.refs[f])}},componentWillUnmount:{value:function(){this._updateRouteComponent(null)}},_updateRouteComponent:{value:function(t){this.context.router.setRouteComponentAtDepth(this.getRouteDepth(),t)}},getRouteDepth:{value:function(){return this.context.routeDepth}},createChildRouteHandler:{value:function(t){var e=this.context.router.getRouteAtDepth(this.getRouteDepth());return e?a.createElement(e.handler,s({},t||this.props,{ref:f})):null}},render:{value:function(){var t=this.createChildRouteHandler();return t?a.createElement(u,null,t):a.createElement("script",null)}}}),e}(a.Component);l.contextTypes={routeDepth:c.number.isRequired,router:c.router.isRequired},l.childContextTypes={routeDepth:c.number.isRequired},t.exports=l},function(t,e,n){"use strict";function r(t){t===u.PUSH&&(s.length+=1);var e={path:l.getCurrentPath(),type:t};c.forEach(function(t){t.call(l,e)})}function o(){var t=l.getCurrentPath();return"/"===t.charAt(0)?!0:(l.replace("/"+t),!1)}function i(){if(o()){var t=a;a=null,r(t||u.POP)}}var a,u=n(24),s=n(14),c=[],f=!1,l={addChangeListener:function(t){c.push(t),o(),f||(window.addEventListener?window.addEventListener("hashchange",i,!1):window.attachEvent("onhashchange",i),f=!0)},removeChangeListener:function(t){c=c.filter(function(e){return e!==t}),0===c.length&&(window.removeEventListener?window.removeEventListener("hashchange",i,!1):window.removeEvent("onhashchange",i),f=!1)},push:function(t){a=u.PUSH,window.location.hash=t},replace:function(t){a=u.REPLACE,window.location.replace(window.location.pathname+window.location.search+"#"+t)},pop:function(){a=u.POP,s.back()},getCurrentPath:function(){return decodeURI(window.location.href.split("#")[1]||"")},toString:function(){return"<HashLocation>"}};t.exports=l},function(t,e,n){"use strict";function r(t){var e={path:c.getCurrentPath(),type:t};u.forEach(function(t){t.call(c,e)})}function o(t){void 0!==t.state&&r(i.POP)}var i=n(24),a=n(14),u=[],s=!1,c={addChangeListener:function(t){u.push(t),s||(window.addEventListener?window.addEventListener("popstate",o,!1):window.attachEvent("onpopstate",o),s=!0)},removeChangeListener:function(t){u=u.filter(function(e){return e!==t}),0===u.length&&(window.addEventListener?window.removeEventListener("popstate",o,!1):window.removeEvent("onpopstate",o),s=!1)},push:function(t){window.history.pushState({path:t},"",t),a.length+=1,r(i.PUSH)},replace:function(t){window.history.replaceState({path:t},"",t),r(i.REPLACE)},pop:a.back,getCurrentPath:function(){return decodeURI(window.location.pathname+window.location.search)},toString:function(){return"<HistoryLocation>"}};t.exports=c},function(t,e,n){"use strict";var r=n(8),o=n(14),i={push:function(t){window.location=t},replace:function(t){window.location.replace(t)},pop:o.back,getCurrentPath:r.getCurrentPath,toString:function(){return"<RefreshLocation>"}};t.exports=i},function(t,e,n){"use strict";function r(){a(!1,"You cannot modify a static location")}var o=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),i=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},a=n(34),u=function(){function t(e){i(this,t),this.path=e}return o(t,{getCurrentPath:{value:function(){return this.path}},toString:{value:function(){return'<StaticLocation path="'+this.path+'">'}}}),t}();u.prototype.push=r,u.prototype.replace=r,u.prototype.pop=r,t.exports=u},function(t,e,n){"use strict";var r=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),o=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},i=n(34),a=n(24),u=n(14),s=function(){function t(e){o(this,t),this.history=e||[],this.listeners=[],this._updateHistoryLength()}return r(t,{needsDOM:{get:function(){return!1}},_updateHistoryLength:{value:function(){u.length=this.history.length}},_notifyChange:{value:function(t){for(var e={path:this.getCurrentPath(),type:t},n=0,r=this.listeners.length;r>n;++n)this.listeners[n].call(this,e)}},addChangeListener:{value:function(t){this.listeners.push(t)}},removeChangeListener:{value:function(t){this.listeners=this.listeners.filter(function(e){return e!==t})}},push:{value:function(t){this.history.push(t),this._updateHistoryLength(),this._notifyChange(a.PUSH)}},replace:{value:function(t){i(this.history.length,"You cannot replace the current path with no history"),this.history[this.history.length-1]=t,this._notifyChange(a.REPLACE)}},pop:{value:function(){this.history.pop(),this._updateHistoryLength(),this._notifyChange(a.POP)}},getCurrentPath:{value:function(){return this.history[this.history.length-1]}},toString:{value:function(){return"<TestLocation>"}}}),t}();t.exports=s},function(t,e,n){"use strict";var r=n(24),o={updateScrollPosition:function(t,e){switch(e){case r.PUSH:case r.REPLACE:window.scrollTo(0,0);break;case r.POP:t?window.scrollTo(t.x,t.y):window.scrollTo(0,0)}}};t.exports=o},function(t){"use strict";var e={updateScrollPosition:function(){window.scrollTo(0,0)}};t.exports=e},function(t,e,n){"use strict";var r=n(34),o=n(35).canUseDOM,i={length:1,back:function(){r(o,"Cannot use History.back without a DOM"),i.length-=1,window.history.back()}};t.exports=i},function(t,e,n){"use strict";function r(t,e){return function(){return o(!1,"Router.Navigation is deprecated. Please use this.context.router."+t+"() instead"),e.apply(this,arguments)}}var o=n(36),i=n(22),a={contextTypes:{router:i.router.isRequired},makePath:r("makePath",function(t,e,n){return this.context.router.makePath(t,e,n)}),makeHref:r("makeHref",function(t,e,n){return this.context.router.makeHref(t,e,n)}),transitionTo:r("transitionTo",function(t,e,n){this.context.router.transitionTo(t,e,n)}),replaceWith:r("replaceWith",function(t,e,n){this.context.router.replaceWith(t,e,n)}),goBack:r("goBack",function(){return this.context.router.goBack()})};t.exports=a},function(t,e,n){"use strict";function r(t,e){return function(){return o(!1,"Router.State is deprecated. Please use this.context.router."+t+"() instead"),e.apply(this,arguments)}}var o=n(36),i=n(22),a={contextTypes:{router:i.router.isRequired},getPath:r("getCurrentPath",function(){return this.context.router.getCurrentPath()}),getPathname:r("getCurrentPathname",function(){return this.context.router.getCurrentPathname()}),getParams:r("getCurrentParams",function(){return this.context.router.getCurrentParams()}),getQuery:r("getCurrentQuery",function(){return this.context.router.getCurrentQuery()}),getRoutes:r("getCurrentRoutes",function(){return this.context.router.getCurrentRoutes()}),isActive:r("isActive",function(t,e,n){return this.context.router.isActive(t,e,n)})};t.exports=a},function(t,e,n){"use strict";var r,o=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),i=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},a=n(33),u=n(34),s=n(36),c=n(25),f=function(){function t(e,n,r,o,a,u,s,f){i(this,t),this.name=e,this.path=n,this.paramNames=c.extractParamNames(this.path),this.ignoreScrollBehavior=!!r,this.isDefault=!!o,this.isNotFound=!!a,this.onEnter=u,this.onLeave=s,this.handler=f}return o(t,{appendChild:{value:function(e){u(e instanceof t,"route.appendChild must use a valid Route"),this.childRoutes||(this.childRoutes=[]),this.childRoutes.push(e)}},toString:{value:function(){var t="<Route";return this.name&&(t+=' name="'+this.name+'"'),t+=' path="'+this.path+'">'}}},{createRoute:{value:function(e,n){e=e||{},"string"==typeof e&&(e={path:e});var o=r;o?s(null==e.parentRoute||e.parentRoute===o,"You should not use parentRoute with createRoute inside another route's child callback; it is ignored"):o=e.parentRoute;var i=e.name,a=e.path||i;!a||e.isDefault||e.isNotFound?a=o?o.path:"/":c.isAbsolute(a)?o&&u(a===o.path||0===o.paramNames.length,'You cannot nest path "%s" inside "%s"; the parent requires URL parameters',a,o.path):a=o?c.join(o.path,a):"/"+a,e.isNotFound&&!/\*$/.test(a)&&(a+="*");var f=new t(i,a,e.ignoreScrollBehavior,e.isDefault,e.isNotFound,e.onEnter,e.onLeave,e.handler);if(o&&(f.isDefault?(u(null==o.defaultRoute,"%s may not have more than one default route",o),o.defaultRoute=f):f.isNotFound&&(u(null==o.notFoundRoute,"%s may not have more than one not found route",o),o.notFoundRoute=f),o.appendChild(f)),"function"==typeof n){var l=r;r=f,n.call(f,f),r=l}return f}},createDefaultRoute:{value:function(e){return t.createRoute(a({},e,{isDefault:!0}))}},createNotFoundRoute:{value:function(e){return t.createRoute(a({},e,{isNotFound:!0}))}},createRedirect:{value:function(e){return t.createRoute(a({},e,{path:e.path||e.from||"*",onEnter:function(t,n,r){t.redirect(e.to,e.params||n,e.query||r)}}))}}}),t}();t.exports=f},function(t,e,n){"use strict";function r(t,e,n){t=t||"UnknownComponent";for(var r in e)if(e.hasOwnProperty(r)){var o=e[r](n,r,t);o instanceof Error&&c(!1,o.message)}}function o(t){var e=s({},t),n=e.handler;return n&&(e.onEnter=n.willTransitionTo,e.onLeave=n.willTransitionFrom),e}function i(t){if(u.isValidElement(t)){var e=t.type,n=s({},e.defaultProps,t.props);return e.propTypes&&r(e.displayName,e.propTypes,n),e===f?h.createDefaultRoute(o(n)):e===l?h.createNotFoundRoute(o(n)):e===p?h.createRedirect(o(n)):h.createRoute(o(n),function(){n.children&&a(n.children)})}}function a(t){var e=[];return u.Children.forEach(t,function(t){(t=i(t))&&e.push(t)}),e}var u=n(21),s=n(33),c=n(36),f=n(1),l=n(3),p=n(4),h=n(17);t.exports=a},function(t,e,n){"use strict";function r(t,e){for(var n in e)if(e.hasOwnProperty(n)&&t[n]!==e[n])return!1;return!0}function o(t,e,n,o,i,a){return t.some(function(t){if(t!==e)return!1;for(var u,s=e.paramNames,c=0,f=s.length;f>c;++c)if(u=s[c],o[u]!==n[u])return!1;return r(i,a)&&r(a,i)})}function i(t,e){for(var n,r=0,o=t.length;o>r;++r)n=t[r],n.name&&(p(null==e[n.name],'You may not have more than one route named "%s"',n.name),e[n.name]=n),n.childRoutes&&i(n.childRoutes,e)}function a(t,e){return t.some(function(t){return t.name===e})}function u(t,e){for(var n in e)if(String(t[n])!==String(e[n]))return!1;return!0}function s(t,e){for(var n in e)if(String(t[n])!==String(e[n]))return!1;return!0}function c(t){t=t||{},x(t)&&(t={routes:t});var e=[],n=t.location||_,r=t.scrollBehavior||k,c={},y={},D=null,N=null;"string"==typeof n&&(n=new w(n)),n instanceof w?l(!h||!1,"You should not use a static location in a DOM environment because the router will not be kept in sync with the current URL"):p(h||n.needsDOM===!1,"You cannot use %s without a DOM",n),n!==m||j()||(n=g);var H=f.createClass({displayName:"Router",statics:{isRunning:!1,cancelPendingTransition:function(){D&&(D.cancel(),D=null)},clearAllRoutes:function(){H.cancelPendingTransition(),H.namedRoutes={},H.routes=[]},addRoutes:function(t){x(t)&&(t=R(t)),i(t,H.namedRoutes),H.routes.push.apply(H.routes,t)},replaceRoutes:function(t){H.clearAllRoutes(),H.addRoutes(t),H.refresh()},match:function(t){return T.findMatch(H.routes,t)},makePath:function(t,e,n){var r;if(A.isAbsolute(t))r=t;else{var o=t instanceof S?t:H.namedRoutes[t];p(o instanceof S,'Cannot find a route named "%s"',t),r=o.path}return A.withQuery(A.injectParams(r,e),n)},makeHref:function(t,e,r){var o=H.makePath(t,e,r);return n===v?"#"+o:o},transitionTo:function(t,e,r){var o=H.makePath(t,e,r);D?n.replace(o):n.push(o)},replaceWith:function(t,e,r){n.replace(H.makePath(t,e,r))},goBack:function(){return E.length>1||n===g?(n.pop(),!0):(l(!1,"goBack() was ignored because there is no router history"),!1)},handleAbort:t.onAbort||function(t){if(n instanceof w)throw new Error("Unhandled aborted transition! Reason: "+t);t instanceof L||(t instanceof O?n.replace(H.makePath(t.to,t.params,t.query)):n.pop())},handleError:t.onError||function(t){throw t},handleLocationChange:function(t){H.dispatch(t.path,t.type)},dispatch:function(t,n){H.cancelPendingTransition();var r=c.path,i=null==n;if(r!==t||i){r&&n===d.PUSH&&H.recordScrollPosition(r);var a=H.match(t);l(null!=a,'No route matches path "%s". Make sure you have <Route path="%s"> somewhere in your routes',t,t),null==a&&(a={});var u,s,f=c.routes||[],p=c.params||{},h=c.query||{},y=a.routes||[],v=a.params||{},m=a.query||{};f.length?(u=f.filter(function(t){return!o(y,t,p,v,h,m)}),s=y.filter(function(t){return!o(f,t,p,v,h,m)})):(u=[],s=y);var g=new P(t,H.replaceWith.bind(H,t));D=g;var w=e.slice(f.length-u.length);P.from(g,u,w,function(e){return e||g.abortReason?N.call(H,e,g):void P.to(g,s,v,m,function(e){N.call(H,e,g,{path:t,action:n,pathname:a.pathname,routes:y,params:v,query:m})})})}},run:function(t){p(!H.isRunning,"Router is already running"),N=function(e,n,r){e&&H.handleError(e),D===n&&(D=null,n.abortReason?H.handleAbort(n.abortReason):t.call(H,H,y=r))},n instanceof w||(n.addChangeListener&&n.addChangeListener(H.handleLocationChange),H.isRunning=!0),H.refresh()},refresh:function(){H.dispatch(n.getCurrentPath(),null)},stop:function(){H.cancelPendingTransition(),n.removeChangeListener&&n.removeChangeListener(H.handleLocationChange),H.isRunning=!1},getLocation:function(){return n},getScrollBehavior:function(){return r},getRouteAtDepth:function(t){var e=c.routes;return e&&e[t]},setRouteComponentAtDepth:function(t,n){e[t]=n},getCurrentPath:function(){return c.path},getCurrentPathname:function(){return c.pathname},getCurrentParams:function(){return c.params},getCurrentQuery:function(){return c.query},getCurrentRoutes:function(){return c.routes},isActive:function(t,e,n){return A.isAbsolute(t)?t===c.path:a(c.routes,t)&&u(c.params,e)&&(null==n||s(c.query,n))}},mixins:[b],propTypes:{children:C.falsy},childContextTypes:{routeDepth:C.number.isRequired,router:C.router.isRequired},getChildContext:function(){return{routeDepth:1,router:H}},getInitialState:function(){return c=y},componentWillReceiveProps:function(){this.setState(c=y)},componentWillUnmount:function(){H.stop()},render:function(){var t=H.getRouteAtDepth(0);return t?f.createElement(t.handler,this.props):null}});return H.clearAllRoutes(),t.routes&&H.addRoutes(t.routes),H}var f=n(21),l=n(36),p=n(34),h=n(35).canUseDOM,d=n(24),y=n(12),v=n(7),m=n(8),g=n(9),w=n(10),b=n(26),R=n(18),x=n(27),P=n(28),C=n(22),O=n(29),E=n(14),L=n(30),T=n(31),S=n(17),j=n(32),A=n(25),_=h?v:"/",k=h?y:null;t.exports=c},function(t,e,n){"use strict";function r(t,e,n){"function"==typeof e&&(n=e,e=null);var r=o({routes:t,location:e});return r.run(n),r}var o=n(19);t.exports=r},function(e){e.exports=t},function(t,e,n){"use strict";var r=n(33),o=n(21).PropTypes,i=n(17),a=r({},o,{falsy:function(t,e,n){return t[e]?new Error("<"+n+'> may not have a "'+e+'" prop'):void 0},route:o.instanceOf(i),router:o.func});t.exports=a},function(t,e,n){"use strict";var r=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),o=function(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(t.__proto__=e)},i=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},a=n(21),u=function(t){function e(){i(this,e),null!=t&&t.apply(this,arguments)}return o(e,t),r(e,{render:{value:function(){return this.props.children}}}),e}(a.Component);t.exports=u},function(t){"use strict";var e={PUSH:"push",REPLACE:"replace",POP:"pop"};t.exports=e},function(t,e,n){"use strict";function r(t){if(!(t in l)){var e=[],n=t.replace(u,function(t,n){return n?(e.push(n),"([^/?#]+)"):"*"===t?(e.push("splat"),"(.*?)"):"\\"+t});l[t]={matcher:new RegExp("^"+n+"$","i"),paramNames:e}}return l[t]}var o=n(34),i=n(38),a=n(39),u=/:([a-zA-Z_$][a-zA-Z0-9_$]*)|[*.()\[\]\\+|{}^$]/g,s=/:([a-zA-Z_$][a-zA-Z0-9_$?]*[?]?)|[*]/g,c=/\/\/\?|\/\?\/|\/\?/g,f=/\?(.*)$/,l={},p={isAbsolute:function(t){return"/"===t.charAt(0)},join:function(t,e){return t.replace(/\/*$/,"/")+e},extractParamNames:function(t){return r(t).paramNames},extractParams:function(t,e){var n=r(t),o=n.matcher,i=n.paramNames,a=e.match(o);if(!a)return null;var u={};return i.forEach(function(t,e){u[t]=a[e+1]}),u},injectParams:function(t,e){e=e||{};var n=0;return t.replace(s,function(r,i){if(i=i||"splat","?"===i.slice(-1)){if(i=i.slice(0,-1),null==e[i])return""}else o(null!=e[i],'Missing "%s" parameter for path "%s"',i,t);var a;return"splat"===i&&Array.isArray(e[i])?(a=e[i][n++],o(null!=a,'Missing splat # %s for path "%s"',n,t)):a=e[i],a}).replace(c,"/")},extractQuery:function(t){var e=t.match(f);return e&&a.parse(e[1])},withoutQuery:function(t){return t.replace(f,"")},withQuery:function(t,e){var n=p.extractQuery(t);n&&(e=e?i(n,e):n);var r=a.stringify(e,{arrayFormat:"brackets"});return r?p.withoutQuery(t)+"?"+r:p.withoutQuery(t)}};t.exports=p},function(t,e,n){"use strict";function r(t,e){if(!e)return!0;if(t.pathname===e.pathname)return!1;var n=t.routes,r=e.routes,o=n.filter(function(t){return-1!==r.indexOf(t)});return!o.some(function(t){return t.ignoreScrollBehavior})}var o=n(34),i=n(35).canUseDOM,a=n(37),u={statics:{recordScrollPosition:function(t){this.scrollHistory||(this.scrollHistory={}),this.scrollHistory[t]=a()},getScrollPosition:function(t){return this.scrollHistory||(this.scrollHistory={}),this.scrollHistory[t]||null}},componentWillMount:function(){o(null==this.constructor.getScrollBehavior()||i,"Cannot use scroll behavior without a DOM")},componentDidMount:function(){this._updateScroll()},componentDidUpdate:function(t,e){this._updateScroll(e)},_updateScroll:function(t){if(r(this.state,t)){var e=this.constructor.getScrollBehavior();e&&e.updateScrollPosition(this.constructor.getScrollPosition(this.state.path),this.state.action)}}};t.exports=u},function(t,e,n){"use strict";function r(t){return null==t||i.isValidElement(t)}function o(t){return r(t)||Array.isArray(t)&&t.every(r)}var i=n(21);t.exports=o},function(t,e,n){"use strict";function r(t,e){this.path=t,this.abortReason=null,this.retry=e.bind(this)}var o=n(30),i=n(29);r.prototype.abort=function(t){null==this.abortReason&&(this.abortReason=t||"ABORT")},r.prototype.redirect=function(t,e,n){this.abort(new i(t,e,n))},r.prototype.cancel=function(){this.abort(new o)},r.from=function(t,e,n,r){e.reduce(function(e,r,o){return function(i){if(i||t.abortReason)e(i);else if(r.onLeave)try{r.onLeave(t,n[o],e),r.onLeave.length<3&&e()}catch(a){e(a)}else e()}},r)()},r.to=function(t,e,n,r,o){e.reduceRight(function(e,o){return function(i){if(i||t.abortReason)e(i);else if(o.onEnter)try{o.onEnter(t,n,r,e),o.onEnter.length<4&&e()}catch(a){e(a)}else e()}},o)()},t.exports=r},function(t){"use strict";function e(t,e,n){this.to=t,this.params=e,this.query=n}t.exports=e},function(t){"use strict";function e(){}t.exports=e},function(t,e,n){"use strict";function r(t,e,n){var o=t.childRoutes;if(o)for(var i,s,c=0,f=o.length;f>c;++c)if(s=o[c],!s.isDefault&&!s.isNotFound&&(i=r(s,e,n)))return i.routes.unshift(t),i;var l=t.defaultRoute;if(l&&(h=a.extractParams(l.path,e)))return new u(e,h,n,[t,l]);var p=t.notFoundRoute;if(p&&(h=a.extractParams(p.path,e)))return new u(e,h,n,[t,p]);var h=a.extractParams(t.path,e);return h?new u(e,h,n,[t]):null}var o=function(){function t(t,e){for(var n in e){var r=e[n];r.configurable=!0,r.value&&(r.writable=!0)}Object.defineProperties(t,e)}return function(e,n,r){return n&&t(e.prototype,n),r&&t(e,r),e}}(),i=function(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")},a=n(25),u=function(){function t(e,n,r,o){i(this,t),this.pathname=e,this.params=n,this.query=r,this.routes=o}return o(t,null,{findMatch:{value:function(t,e){for(var n=a.withoutQuery(e),o=a.extractQuery(e),i=null,u=0,s=t.length;null==i&&s>u;++u)i=r(t[u],n,o);return i}}}),t}();t.exports=u},function(t){"use strict";function e(){/*! taken from modernizr
	   * https://github.com/Modernizr/Modernizr/blob/master/LICENSE
	   * https://github.com/Modernizr/Modernizr/blob/master/feature-detects/history.js
	   * changed to avoid false negatives for Windows Phones: https://github.com/rackt/react-router/issues/586
	   */
var t=navigator.userAgent;return-1===t.indexOf("Android 2.")&&-1===t.indexOf("Android 4.0")||-1===t.indexOf("Mobile Safari")||-1!==t.indexOf("Chrome")||-1!==t.indexOf("Windows Phone")?window.history&&"pushState"in window.history:!1}t.exports=e},function(t){"use strict";function e(t){if(null==t)throw new TypeError("Object.assign target cannot be null or undefined");for(var e=Object(t),n=Object.prototype.hasOwnProperty,r=1;r<arguments.length;r++){var o=arguments[r];if(null!=o){var i=Object(o);for(var a in i)n.call(i,a)&&(e[a]=i[a])}}return e}t.exports=e},function(t){"use strict";var e=function(t,e,n,r,o,i,a,u){if(!t){var s;if(void 0===e)s=new Error("Minified exception occurred; use the non-minified dev environment for the full error message and additional helpful warnings.");else{var c=[n,r,o,i,a,u],f=0;s=new Error("Invariant Violation: "+e.replace(/%s/g,function(){return c[f++]}))}throw s.framesToPop=1,s}};t.exports=e},function(t){"use strict";var e=!("undefined"==typeof window||!window.document||!window.document.createElement),n={canUseDOM:e,canUseWorkers:"undefined"!=typeof Worker,canUseEventListeners:e&&!(!window.addEventListener&&!window.attachEvent),canUseViewport:e&&!!window.screen,isInWorker:!e};t.exports=n},function(t,e,n){"use strict";var r=n(40),o=r;t.exports=o},function(t,e,n){"use strict";function r(){return o(i,"Cannot get current scroll position without a DOM"),{x:window.pageXOffset||document.documentElement.scrollLeft,y:window.pageYOffset||document.documentElement.scrollTop}}var o=n(34),i=n(35).canUseDOM;t.exports=r},function(t){"use strict";function e(t){if(null==t)throw new TypeError("Object.assign cannot be called with null or undefined");return Object(t)}t.exports=Object.assign||function(t){for(var n,r,o=e(t),i=1;i<arguments.length;i++){n=arguments[i],r=Object.keys(Object(n));for(var a=0;a<r.length;a++)o[r[a]]=n[r[a]]}return o}},function(t,e,n){"use strict";t.exports=n(41)},function(t){"use strict";function e(t){return function(){return t}}function n(){}n.thatReturns=e,n.thatReturnsFalse=e(!1),n.thatReturnsTrue=e(!0),n.thatReturnsNull=e(null),n.thatReturnsThis=function(){return this},n.thatReturnsArgument=function(t){return t},t.exports=n},function(t,e,n){"use strict";var r=n(42),o=n(43);t.exports={stringify:r,parse:o}},function(t,e,n){"use strict";var r=n(44),o={delimiter:"&",arrayPrefixGenerators:{brackets:function(t){return t+"[]"},indices:function(t,e){return t+"["+e+"]"},repeat:function(t){return t}}};o.stringify=function(t,e,n){if(r.isBuffer(t)?t=t.toString():t instanceof Date?t=t.toISOString():null===t&&(t=""),"string"==typeof t||"number"==typeof t||"boolean"==typeof t)return[encodeURIComponent(e)+"="+encodeURIComponent(t)];var i=[];if("undefined"==typeof t)return i;for(var a=Object.keys(t),u=0,s=a.length;s>u;++u){var c=a[u];i=i.concat(Array.isArray(t)?o.stringify(t[c],n(e,c),n):o.stringify(t[c],e+"["+c+"]",n))}return i},t.exports=function(t,e){e=e||{};var n="undefined"==typeof e.delimiter?o.delimiter:e.delimiter,r=[];if("object"!=typeof t||null===t)return"";var i;i=e.arrayFormat in o.arrayPrefixGenerators?e.arrayFormat:"indices"in e?e.indices?"indices":"repeat":"indices";for(var a=o.arrayPrefixGenerators[i],u=Object.keys(t),s=0,c=u.length;c>s;++s){var f=u[s];r=r.concat(o.stringify(t[f],f,a))}return r.join(n)}},function(t,e,n){"use strict";var r=n(44),o={delimiter:"&",depth:5,arrayLimit:20,parameterLimit:1e3};o.parseValues=function(t,e){for(var n={},o=t.split(e.delimiter,1/0===e.parameterLimit?void 0:e.parameterLimit),i=0,a=o.length;a>i;++i){var u=o[i],s=-1===u.indexOf("]=")?u.indexOf("="):u.indexOf("]=")+1;if(-1===s)n[r.decode(u)]="";else{var c=r.decode(u.slice(0,s)),f=r.decode(u.slice(s+1));if(Object.prototype.hasOwnProperty(c))continue;n[c]=n.hasOwnProperty(c)?[].concat(n[c]).concat(f):f}}return n},o.parseObject=function(t,e,n){if(!t.length)return e;var r=t.shift(),i={};if("[]"===r)i=[],i=i.concat(o.parseObject(t,e,n));else{var a="["===r[0]&&"]"===r[r.length-1]?r.slice(1,r.length-1):r,u=parseInt(a,10),s=""+u;!isNaN(u)&&r!==a&&s===a&&u>=0&&u<=n.arrayLimit?(i=[],i[u]=o.parseObject(t,e,n)):i[a]=o.parseObject(t,e,n)}return i},o.parseKeys=function(t,e,n){if(t){var r=/^([^\[\]]*)/,i=/(\[[^\[\]]*\])/g,a=r.exec(t);if(!Object.prototype.hasOwnProperty(a[1])){var u=[];a[1]&&u.push(a[1]);for(var s=0;null!==(a=i.exec(t))&&s<n.depth;)++s,Object.prototype.hasOwnProperty(a[1].replace(/\[|\]/g,""))||u.push(a[1]);return a&&u.push("["+t.slice(a.index)+"]"),o.parseObject(u,e,n)}}},t.exports=function(t,e){if(""===t||null===t||"undefined"==typeof t)return{};e=e||{},e.delimiter="string"==typeof e.delimiter||r.isRegExp(e.delimiter)?e.delimiter:o.delimiter,e.depth="number"==typeof e.depth?e.depth:o.depth,e.arrayLimit="number"==typeof e.arrayLimit?e.arrayLimit:o.arrayLimit,e.parameterLimit="number"==typeof e.parameterLimit?e.parameterLimit:o.parameterLimit;for(var n="string"==typeof t?o.parseValues(t,e):t,i={},a=Object.keys(n),u=0,s=a.length;s>u;++u){var c=a[u],f=o.parseKeys(c,n[c],e);i=r.merge(i,f)}return r.compact(i)}},function(t,e){"use strict";e.arrayToObject=function(t){for(var e={},n=0,r=t.length;r>n;++n)"undefined"!=typeof t[n]&&(e[n]=t[n]);return e},e.merge=function(t,n){if(!n)return t;if("object"!=typeof n)return Array.isArray(t)?t.push(n):t[n]=!0,t;if("object"!=typeof t)return t=[t].concat(n);Array.isArray(t)&&!Array.isArray(n)&&(t=e.arrayToObject(t));for(var r=Object.keys(n),o=0,i=r.length;i>o;++o){var a=r[o],u=n[a];t[a]=t[a]?e.merge(t[a],u):u}return t},e.decode=function(t){try{return decodeURIComponent(t.replace(/\+/g," "))}catch(e){return t}},e.compact=function(t,n){if("object"!=typeof t||null===t)return t;n=n||[];var r=n.indexOf(t);if(-1!==r)return n[r];if(n.push(t),Array.isArray(t)){for(var o=[],i=0,a=t.length;a>i;++i)"undefined"!=typeof t[i]&&o.push(t[i]);return o}var u=Object.keys(t);for(i=0,a=u.length;a>i;++i){var s=u[i];t[s]=e.compact(t[s],n)}return t},e.isRegExp=function(t){return"[object RegExp]"===Object.prototype.toString.call(t)},e.isBuffer=function(t){return null===t||"undefined"==typeof t?!1:!!(t.constructor&&t.constructor.isBuffer&&t.constructor.isBuffer(t))}}])});
!function(t,n){"object"==typeof exports&&"object"==typeof module?module.exports=n():"function"==typeof define&&define.amd?define(n):"object"==typeof exports?exports.Fluxxor=n():t.Fluxxor=n()}(this,function(){return function(t){function n(e){if(r[e])return r[e].exports;var o=r[e]={exports:{},id:e,loaded:!1};return t[e].call(o.exports,o,o.exports,n),o.loaded=!0,o.exports}var r={};return n.m=t,n.c=r,n.p="",n(0)}([function(t,n,r){var e=r(18),o=r(29),i=r(31),c=r(30),u=r(33),a=r(28),s={Dispatcher:e,Flux:o,FluxMixin:i,FluxChildMixin:c,StoreWatchMixin:u,createStore:a,version:r(79)};t.exports=s},function(t){function n(t){return"number"==typeof t&&t>-1&&t%1==0&&r>=t}var r=Math.pow(2,53)-1;t.exports=n},function(t,n,r){function e(t){return null==t?!1:f.call(t)==c?p.test(s.call(t)):i(t)&&u.test(t)||!1}var o=r(77),i=r(8),c="[object Function]",u=/^\[object .+?Constructor\]$/,a=Object.prototype,s=Function.prototype.toString,f=a.toString,p=RegExp("^"+o(f).replace(/toString|(function).*?(?=\\\()| for .+?(?=\\\])/g,"$1.*?")+"$");t.exports=e},function(t){function n(t){var n=typeof t;return"function"==n||t&&"object"==n||!1}t.exports=n},function(t,n,r){var e=r(1),o=r(2),i=r(8),c="[object Array]",u=Object.prototype,a=u.toString,s=o(s=Array.isArray)&&s,f=s||function(t){return i(t)&&e(t.length)&&a.call(t)==c||!1};t.exports=f},function(t,n,r){var e=r(1),o=r(2),i=r(3),c=r(68),u=o(u=Object.keys)&&u,a=u?function(t){if(t)var n=t.constructor,r=t.length;return"function"==typeof n&&n.prototype===t||"function"!=typeof t&&r&&e(r)?c(t):i(t)?u(t):[]}:c;t.exports=a},function(t,n,r){function e(t,n,r){var e=typeof t;return"function"==e?"undefined"!=typeof n&&a(t)?c(t,n,r):t:null==t?u:"object"==e?o(t,!r):i(t+"")}var o=r(50),i=r(51),c=r(10),u=r(17),a=r(65);t.exports=e},function(t,n,r){function e(t,n){return o(t,n,i)}var o=r(45),i=r(5);t.exports=e},function(t){function n(t){return t&&"object"==typeof t||!1}t.exports=n},function(t,n,r){function e(t,n,r){return"function"==typeof n&&"undefined"==typeof r&&u(t)?o(t,n):i(t,c(n,r,3))}var o=r(20),i=r(12),c=r(10),u=r(4);t.exports=e},function(t,n,r){function e(t,n,r){if("function"!=typeof t)return o;if("undefined"==typeof n)return t;switch(r){case 1:return function(r){return t.call(n,r)};case 3:return function(r,e,o){return t.call(n,r,e,o)};case 4:return function(r,e,o,i){return t.call(n,r,e,o,i)};case 5:return function(r,e,o,i,c){return t.call(n,r,e,o,i,c)}}return function(){return t.apply(n,arguments)}}var o=r(17);t.exports=e},function(t){t.exports="function"==typeof Object.create?function(t,n){t.super_=n,t.prototype=Object.create(n.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}})}:function(t,n){t.super_=n;var r=function(){};r.prototype=n.prototype,t.prototype=new r,t.prototype.constructor=t}},function(t,n,r){function e(t,n){var r=t?t.length:0;if(!i(r))return o(t,n);for(var e=-1,u=c(t);++e<r&&n(u[e],e,u)!==!1;);return t}var o=r(7),i=r(1),c=r(26);t.exports=e},function(t){function n(t,n){return t=+t,n=null==n?r:n,t>-1&&t%1==0&&n>t}var r=Math.pow(2,53)-1;t.exports=n},function(t,n,r){function e(t){var n=i(t)?t.length:void 0;return o(n)&&a.call(t)==c||!1}var o=r(1),i=r(8),c="[object Arguments]",u=Object.prototype,a=u.toString;t.exports=e},function(t,n,r){(function(n){function e(t){return"function"==typeof t||!1}var o=r(2),i="[object Function]",c=Object.prototype,u=c.toString,a=o(a=n.Uint8Array)&&a;(e(/x/)||a&&!e(a))&&(e=function(t){return u.call(t)==i}),t.exports=e}).call(n,function(){return this}())},function(t,n,r){(function(n){var e=r(2),o=/\bthis\b/,i=Object.prototype,c=(c=n.window)&&c.document,u=i.propertyIsEnumerable,a={};!function(){a.funcDecomp=!e(n.WinRTError)&&o.test(function(){return this}),a.funcNames="string"==typeof Function.name;try{a.dom=11===c.createDocumentFragment().nodeType}catch(t){a.dom=!1}try{a.nonEnumArgs=!u.call(arguments,1)}catch(t){a.nonEnumArgs=!0}}(0,0),t.exports=a}).call(n,function(){return this}())},function(t){function n(t){return t}t.exports=n},function(t,n,r){var e=r(70),o=r(76),i=r(74),c=r(34),u=r(5),a=r(36),s=r(9),f=r(38),p=r(73),l=r(35),h=function(t){this.stores={},this.currentDispatch=null,this.currentActionType=null,this.waitingToDispatch=[];for(var n in t)t.hasOwnProperty(n)&&this.addStore(n,t[n])};h.prototype.addStore=function(t,n){n.dispatcher=this,this.stores[t]=n},h.prototype.dispatch=function(t){if(!t||!t.type)throw new Error("Can only dispatch actions with a 'type' property");if(this.currentDispatch){var n="Cannot dispatch an action ('"+t.type+"') while another action ('"+this.currentActionType+"') is being dispatched";throw new Error(n)}this.waitingToDispatch=e(this.stores),this.currentActionType=t.type,this.currentDispatch=o(this.stores,function(){return{resolved:!1,waitingOn:[],waitCallback:null}});try{this.doDispatchLoop(t)}finally{this.currentActionType=null,this.currentDispatch=null}},h.prototype.doDispatchLoop=function(t){var n,r,e=!1,o=[],p=[];if(i(this.waitingToDispatch,function(i,s){if(n=this.currentDispatch[s],r=!n.waitingOn.length||!c(n.waitingOn,u(this.waitingToDispatch)).length){if(n.waitCallback){var f=a(n.waitingOn,function(t){return this.stores[t]},this),l=n.waitCallback;n.waitCallback=null,n.waitingOn=[],n.resolved=!0,l.apply(null,f),e=!0}else{n.resolved=!0;var h=this.stores[s].__handleAction__(t);h&&(e=!0)}p.push(s),this.currentDispatch[s].resolved&&o.push(s)}},this),u(this.waitingToDispatch).length&&!p.length){var l=u(this.waitingToDispatch).join(", ");throw new Error("Indirect circular wait detected among: "+l)}s(o,function(t){delete this.waitingToDispatch[t]},this),f(this.waitingToDispatch)&&this.doDispatchLoop(t),!e&&console&&console.warn&&console.warn("An action of type "+t.type+" was dispatched, but no store handled it")},h.prototype.waitForStores=function(t,n,r){if(!this.currentDispatch)throw new Error("Cannot wait unless an action is being dispatched");var e=p(this.stores,function(n){return n===t});if(n.indexOf(e)>-1)throw new Error("A store cannot wait on itself");var o=this.currentDispatch[e];if(o.waitingOn.length)throw new Error(e+" already waiting on stores");s(n,function(t){var n=this.currentDispatch[t];if(!this.stores[t])throw new Error("Cannot wait for non-existent store "+t);if(n.waitingOn.indexOf(e)>-1)throw new Error("Circular wait detected between "+e+" and "+t)},this),o.resolved=!1,o.waitingOn=l(o.waitingOn.concat(n)),o.waitCallback=r},t.exports=h},function(t){"use strict";function n(t,n,r){this.fn=t,this.context=n,this.once=r||!1}function r(){}r.prototype._events=void 0,r.prototype.listeners=function(t){if(!this._events||!this._events[t])return[];if(this._events[t].fn)return[this._events[t].fn];for(var n=0,r=this._events[t].length,e=new Array(r);r>n;n++)e[n]=this._events[t][n].fn;return e},r.prototype.emit=function(t,n,r,e,o,i){if(!this._events||!this._events[t])return!1;var c,u,a=this._events[t],s=arguments.length;if("function"==typeof a.fn){switch(a.once&&this.removeListener(t,a.fn,!0),s){case 1:return a.fn.call(a.context),!0;case 2:return a.fn.call(a.context,n),!0;case 3:return a.fn.call(a.context,n,r),!0;case 4:return a.fn.call(a.context,n,r,e),!0;case 5:return a.fn.call(a.context,n,r,e,o),!0;case 6:return a.fn.call(a.context,n,r,e,o,i),!0}for(u=1,c=new Array(s-1);s>u;u++)c[u-1]=arguments[u];a.fn.apply(a.context,c)}else{var f,p=a.length;for(u=0;p>u;u++)switch(a[u].once&&this.removeListener(t,a[u].fn,!0),s){case 1:a[u].fn.call(a[u].context);break;case 2:a[u].fn.call(a[u].context,n);break;case 3:a[u].fn.call(a[u].context,n,r);break;default:if(!c)for(f=1,c=new Array(s-1);s>f;f++)c[f-1]=arguments[f];a[u].fn.apply(a[u].context,c)}}return!0},r.prototype.on=function(t,r,e){var o=new n(r,e||this);return this._events||(this._events={}),this._events[t]?this._events[t].fn?this._events[t]=[this._events[t],o]:this._events[t].push(o):this._events[t]=o,this},r.prototype.once=function(t,r,e){var o=new n(r,e||this,!0);return this._events||(this._events={}),this._events[t]?this._events[t].fn?this._events[t]=[this._events[t],o]:this._events[t].push(o):this._events[t]=o,this},r.prototype.removeListener=function(t,n,r){if(!this._events||!this._events[t])return this;var e=this._events[t],o=[];if(n&&(e.fn&&(e.fn!==n||r&&!e.once)&&o.push(e),!e.fn))for(var i=0,c=e.length;c>i;i++)(e[i].fn!==n||r&&!e[i].once)&&o.push(e[i]);return o.length?this._events[t]=1===o.length?o[0]:o:delete this._events[t],this},r.prototype.removeAllListeners=function(t){return this._events?(t?delete this._events[t]:this._events={},this):this},r.prototype.off=r.prototype.removeListener,r.prototype.addListener=r.prototype.on,r.prototype.setMaxListeners=function(){return this},r.EventEmitter=r,r.EventEmitter2=r,r.EventEmitter3=r,t.exports=r},function(t){function n(t,n){for(var r=-1,e=t.length;++r<e&&n(t[r],r,t)!==!1;);return t}t.exports=n},function(t,n,r){function e(t,n,r,y,x,d,b){var w;if(r&&(w=x?r(t,y,x):r(t)),"undefined"!=typeof w)return w;if(!l(t))return t;var j=p(t);if(j){if(w=a(t),!n)return o(t,w)}else{var A=R.call(t),_=A==g;if(A!=m&&A!=v&&(!_||x))return L[A]?s(t,A,n):x?t:{};if(w=f(_?{}:t),!n)return c(t,w,h(t))}d||(d=[]),b||(b=[]);for(var O=d.length;O--;)if(d[O]==t)return b[O];return d.push(t),b.push(w),(j?i:u)(t,function(o,i){w[i]=e(o,n,r,i,t,d,b)}),w}var o=r(40),i=r(20),c=r(43),u=r(7),a=r(62),s=r(63),f=r(64),p=r(4),l=r(3),h=r(5),v="[object Arguments]",y="[object Array]",x="[object Boolean]",d="[object Date]",b="[object Error]",g="[object Function]",w="[object Map]",j="[object Number]",m="[object Object]",A="[object RegExp]",_="[object Set]",O="[object String]",F="[object WeakMap]",E="[object ArrayBuffer]",S="[object Float32Array]",D="[object Float64Array]",M="[object Int8Array]",T="[object Int16Array]",C="[object Int32Array]",k="[object Uint8Array]",P="[object Uint8ClampedArray]",U="[object Uint16Array]",I="[object Uint32Array]",L={};L[v]=L[y]=L[E]=L[x]=L[d]=L[S]=L[D]=L[M]=L[T]=L[C]=L[j]=L[m]=L[A]=L[O]=L[k]=L[P]=L[U]=L[I]=!0,L[b]=L[g]=L[w]=L[_]=L[F]=!1;var N=Object.prototype,R=N.toString;t.exports=e},function(t,n,r){function e(t,n,r){if(n!==n)return o(t,r);for(var e=(r||0)-1,i=t.length;++e<i;)if(t[e]===n)return e;return-1}var o=r(61);t.exports=e},function(t,n,r){function e(t,n){var r=t.data,e="string"==typeof n||o(n)?r.set.has(n):r.hash[n];return e?0:-1}var o=r(3);t.exports=e},function(t,n,r){(function(n){var e=r(39),o=r(27),i=r(2),c=i(c=n.Set)&&c,u=i(u=Object.create)&&u,a=u&&c?function(t){return new e(t)}:o(null);t.exports=a}).call(n,function(){return this}())},function(t,n,r){function e(t,n,r){if(!c(r))return!1;var e=typeof n;if("number"==e)var u=r.length,a=i(u)&&o(n,u);else a="string"==e&&n in t;return a&&r[n]===t}var o=r(13),i=r(1),c=r(3);t.exports=e},function(t,n,r){function e(t){return o(t)?t:Object(t)}var o=r(3);t.exports=e},function(t){function n(t){return function(){return t}}t.exports=n},function(t,n,r){var e=r(9),o=r(15),i=r(32),c=r(11),u=["flux","waitFor"],a=function(t){e(u,function(n){if(t[n])throw new Error("Reserved key '"+n+"' found in store definition")});var n=function(n){n=n||{},i.call(this);for(var r in t)"actions"===r?this.bindActions(t[r]):"initialize"===r||(this[r]=o(t[r])?t[r].bind(this):t[r]);t.initialize&&t.initialize.call(this,n)};return c(n,i),n};t.exports=a},function(t,n,r){var e=r(19),o=r(11),i=r(78),c=r(9),u=r(37),a=r(15),s=r(71),f=r(18),p=function(t,n,r){n=n||[];for(var e in t)t.hasOwnProperty(e)&&(a(t[e])?r(n.concat(e),t[e]):p(t[e],n.concat(e),r))},l=function(t,n){e.call(this),this.dispatcher=new f(t),this.actions={},this.stores={};var r=this.dispatcher,o=this;this.dispatchBinder={flux:o,dispatch:function(t,n){try{o.emit("dispatch",t,n)}finally{r.dispatch({type:t,payload:n})}}},this.addActions(n),this.addStores(t)};o(l,e),l.prototype.addActions=function(t){p(t,[],this.addAction.bind(this))},l.prototype.addAction=function(){if(arguments.length<2)throw new Error("addAction requires at least two arguments, a string (or array of strings) and a function");var t=Array.prototype.slice.call(arguments);if(!a(t[t.length-1]))throw new Error("The last argument to addAction must be a function");var n=t.pop().bind(this.dispatchBinder);s(t[0])||(t=t[0]);var r=u(t,function(t,n){if(t){var r=t[t.length-1].concat([n]);return t.concat([r])}return[[n]]},null);if(c(r,function(n){if(a(i.get(this.actions,n)))throw new Error("An action named "+t.join(".")+" already exists")},this),i.get(this.actions,t))throw new Error("A namespace named "+t.join(".")+" already exists");i.set(this.actions,t,n,!0)},l.prototype.store=function(t){return this.stores[t]},l.prototype.addStore=function(t,n){if(t in this.stores)throw new Error("A store named '"+t+"' already exists");n.flux=this,this.stores[t]=n,this.dispatcher.addStore(t,n)},l.prototype.addStores=function(t){for(var n in t)t.hasOwnProperty(n)&&this.addStore(n,t[n])},t.exports=l},function(t){var n=function(t){return{componentWillMount:function(){if(console&&console.warn){var t=this.constructor.displayName?" in "+this.constructor.displayName:"",n="Fluxxor.FluxChildMixin was found in use"+t+", but has been deprecated. Use Fluxxor.FluxMixin instead.";console.warn(n)}},contextTypes:{flux:t.PropTypes.object},getFlux:function(){return this.context.flux}}};n.componentWillMount=function(){throw new Error("Fluxxor.FluxChildMixin is a function that takes React as a parameter and returns the mixin, e.g.: mixins[Fluxxor.FluxChildMixin(React)]")},t.exports=n},function(t){var n=function(t){return{componentWillMount:function(){if(!(this.props.flux||this.context&&this.context.flux)){var t=this.constructor.displayName?" of "+this.constructor.displayName:"";throw new Error("Could not find flux on this.props or this.context"+t)}},childContextTypes:{flux:t.PropTypes.object},contextTypes:{flux:t.PropTypes.object},getChildContext:function(){return{flux:this.getFlux()}},getFlux:function(){return this.props.flux||this.context&&this.context.flux}}};n.componentWillMount=function(){throw new Error("Fluxxor.FluxMixin is a function that takes React as a parameter and returns the mixin, e.g.: mixins: [Fluxxor.FluxMixin(React)]")},t.exports=n},function(t,n,r){function e(t){this.dispatcher=t,this.__actions__={},o.call(this)}var o=r(19),i=r(11),c=r(15),u=r(3);i(e,o),e.prototype.__handleAction__=function(t){var n;if(n=this.__actions__[t.type]){if(c(n))n.call(this,t.payload,t.type);else{if(!n||!c(this[n]))throw new Error("The handler for action type "+t.type+" is not a function");this[n].call(this,t.payload,t.type)}return!0}return!1},e.prototype.bindActions=function(){var t=Array.prototype.slice.call(arguments);if(t.length>1&&t.length%2!==0)throw new Error("bindActions must take an even number of arguments.");var n=function(t,n){if(!n)throw new Error("The handler for action type "+t+" is falsy");this.__actions__[t]=n}.bind(this);if(1===t.length&&u(t[0])){t=t[0];for(var r in t)t.hasOwnProperty(r)&&n(r,t[r])}else for(var e=0;e<t.length;e+=2){var o=t[e],i=t[e+1];if(!o)throw new Error("Argument "+(e+1)+" to bindActions is a falsy value");n(o,i)}},e.prototype.waitFor=function(t,n){this.dispatcher.waitForStores(this,t,n.bind(this))},t.exports=e},function(t,n,r){var e=r(9),o=function(){var t=Array.prototype.slice.call(arguments);return{componentDidMount:function(){var n=this.props.flux||this.context.flux;e(t,function(t){n.store(t).on("change",this._setStateFromFlux)},this)},componentWillUnmount:function(){var n=this.props.flux||this.context.flux;e(t,function(t){n.store(t).removeListener("change",this._setStateFromFlux)},this)},_setStateFromFlux:function(){this.isMounted()&&this.setState(this.getStateFromFlux())},getInitialState:function(){return this.getStateFromFlux()}}};o.componentWillMount=function(){throw new Error('Fluxxor.StoreWatchMixin is a function that takes one or more store names as parameters and returns the mixin, e.g.: mixins: [Fluxxor.StoreWatchMixin("Store1", "Store2")]')},t.exports=o},function(t,n,r){function e(){for(var t=[],n=-1,r=arguments.length,e=[],s=o,f=!0;++n<r;){var p=arguments[n];(a(p)||u(p))&&(t.push(p),e.push(f&&p.length>=120&&c(n&&p)))}r=t.length;var l=t[0],h=-1,v=l?l.length:0,y=[],x=e[0];t:for(;++h<v;)if(p=l[h],(x?i(x,p):s(y,p))<0){for(n=r;--n;){var d=e[n];if((d?i(d,p):s(t[n],p))<0)continue t}x&&x.push(p),y.push(p)}return y}var o=r(22),i=r(23),c=r(24),u=r(14),a=r(4);t.exports=e},function(t,n,r){function e(t,n,r,e){var a=t?t.length:0;return a?("boolean"!=typeof n&&null!=n&&(e=r,r=c(t,n,e)?null:n,n=!1),r=null==r?r:o(r,e,3),n?u(t,r):i(t,r)):[]}var o=r(6),i=r(55),c=r(25),u=r(69);t.exports=e},function(t,n,r){function e(t,n,r){var e=u(t)?o:c;return n=i(n,r,3),e(t,n)}var o=r(41),i=r(6),c=r(49),u=r(4);t.exports=e},function(t,n,r){function e(t,n,r,e){var s=a(t)?o:u;return s(t,i(n,e,4),r,arguments.length<3,c)}var o=r(42),i=r(6),c=r(12),u=r(52),a=r(4);t.exports=e},function(t,n,r){function e(t){var n=t?t.length:0;return o(n)?n:i(t).length}var o=r(1),i=r(5);t.exports=e},function(t,n,r){(function(n){function e(t){var n=t?t.length:0;for(this.data={hash:u(null),set:new c};n--;)this.push(t[n])}var o=r(57),i=r(2),c=i(c=n.Set)&&c,u=i(u=Object.create)&&u;e.prototype.push=o,t.exports=e}).call(n,function(){return this}())},function(t){function n(t,n){var r=-1,e=t.length;for(n||(n=Array(e));++r<e;)n[r]=t[r];return n}t.exports=n},function(t){function n(t,n){for(var r=-1,e=t.length,o=Array(e);++r<e;)o[r]=n(t[r],r,t);return o}t.exports=n},function(t){function n(t,n,r,e){var o=-1,i=t.length;for(e&&i&&(r=t[++o]);++o<i;)r=n(r,t[o],o,t);return r}t.exports=n},function(t){function n(t,n,r){r||(r=n,n={});for(var e=-1,o=r.length;++e<o;){var i=r[e];n[i]=t[i]}return n}t.exports=n},function(t){function n(t,n,r,e){var o;return r(t,function(t,r,i){return n(t,r,i)?(o=e?r:t,!1):void 0}),o}t.exports=n},function(t,n,r){function e(t,n,r){for(var e=-1,i=o(t),c=r(t),u=c.length;++e<u;){var a=c[e];if(n(i[a],a,i)===!1)break}return t}var o=r(26);t.exports=e},function(t,n,r){function e(t,n,r,i,c,u){if(t===n)return 0!==t||1/t==1/n;var a=typeof t,s=typeof n;return"function"!=a&&"object"!=a&&"function"!=s&&"object"!=s||null==t||null==n?t!==t&&n!==n:o(t,n,e,r,i,c,u)}var o=r(47);t.exports=e},function(t,n,r){function e(t,n,r,e,l,y,x){var d=u(t),b=u(n),g=f,w=f;d||(g=v.call(t),g==s?g=p:g!=p&&(d=a(t))),b||(w=v.call(n),w==s?w=p:w!=p&&(b=a(n)));var j=g==p,m=w==p,A=g==w;if(A&&!d&&!j)return i(t,n,g);var _=j&&h.call(t,"__wrapped__"),O=m&&h.call(n,"__wrapped__");if(_||O)return r(_?t.value():t,O?n.value():n,e,l,y,x);if(!A)return!1;y||(y=[]),x||(x=[]);for(var F=y.length;F--;)if(y[F]==t)return x[F]==n;y.push(t),x.push(n);var E=(d?o:c)(t,n,r,e,l,y,x);return y.pop(),x.pop(),E}var o=r(58),i=r(59),c=r(60),u=r(4),a=r(72),s="[object Arguments]",f="[object Array]",p="[object Object]",l=Object.prototype,h=l.hasOwnProperty,v=l.toString;t.exports=e},function(t,n,r){function e(t,n,r,e,i){var u=n.length;if(null==t)return!u;for(var a=-1,s=!i;++a<u;)if(s&&e[a]?r[a]!==t[n[a]]:!c.call(t,n[a]))return!1;for(a=-1;++a<u;){var f=n[a];if(s&&e[a])var p=c.call(t,f);else{var l=t[f],h=r[a];p=i?i(l,h,f):void 0,"undefined"==typeof p&&(p=o(h,l,i,!0))}if(!p)return!1}return!0}var o=r(46),i=Object.prototype,c=i.hasOwnProperty;t.exports=e},function(t,n,r){function e(t,n){var r=[];return o(t,function(t,e,o){r.push(n(t,e,o))}),r}var o=r(12);t.exports=e},function(t,n,r){function e(t,n){var r=u(t),e=r.length;if(1==e){var a=r[0],f=t[a];if(c(f))return function(t){return null!=t&&f===t[a]&&s.call(t,a)}}n&&(t=o(t,!0));for(var p=Array(e),l=Array(e);e--;)f=t[r[e]],p[e]=f,l[e]=c(f);return function(t){return i(t,r,p,l)}}var o=r(21),i=r(48),c=r(66),u=r(5),a=Object.prototype,s=a.hasOwnProperty;t.exports=e},function(t){function n(t){return function(n){return null==n?void 0:n[t]}}t.exports=n},function(t){function n(t,n,r,e,o){return o(t,function(t,o,i){r=e?(e=!1,t):n(r,t,o,i)}),r}t.exports=n},function(t,n,r){var e=r(17),o=r(67),i=o?function(t,n){return o.set(t,n),t}:e;t.exports=i},function(t){function n(t){return"string"==typeof t?t:null==t?"":t+""}t.exports=n},function(t,n,r){function e(t,n){var r=-1,e=o,u=t.length,a=!0,s=a&&u>=200,f=s&&c(),p=[];f?(e=i,a=!1):(s=!1,f=n?[]:p);t:for(;++r<u;){var l=t[r],h=n?n(l,r,t):l;if(a&&l===l){for(var v=f.length;v--;)if(f[v]===h)continue t;n&&f.push(h),p.push(l)}else e(f,h)<0&&((n||s)&&f.push(h),p.push(l))}return p}var o=r(22),i=r(23),c=r(24);t.exports=e},function(t,n,r){(function(n){function e(t){return u.call(t,0)}var o=r(27),i=r(2),c=i(c=n.ArrayBuffer)&&c,u=i(u=c&&new c(0).slice)&&u,a=Math.floor,s=i(s=n.Uint8Array)&&s,f=function(){try{var t=i(t=n.Float64Array)&&t,r=new t(new c(10),0,1)&&t}catch(e){}return r}(),p=f?f.BYTES_PER_ELEMENT:0;u||(e=c&&s?function(t){var n=t.byteLength,r=f?a(n/p):0,e=r*p,o=new c(n);if(r){var i=new f(o,0,r);i.set(new f(t,0,r))}return n!=e&&(i=new s(o,e),i.set(new s(t,e))),o}:o(null)),t.exports=e}).call(n,function(){return this}())},function(t,n,r){function e(t){var n=this.data;"string"==typeof t||o(t)?n.set.add(t):n.hash[t]=!0}var o=r(3);t.exports=e},function(t){function n(t,n,r,e,o,i,c){var u=-1,a=t.length,s=n.length,f=!0;if(a!=s&&!(o&&s>a))return!1;for(;f&&++u<a;){var p=t[u],l=n[u];if(f=void 0,e&&(f=o?e(l,p,u):e(p,l,u)),"undefined"==typeof f)if(o)for(var h=s;h--&&(l=n[h],!(f=p&&p===l||r(p,l,e,o,i,c))););else f=p&&p===l||r(p,l,e,o,i,c)}return!!f}t.exports=n},function(t){function n(t,n,a){switch(a){case r:case e:return+t==+n;case o:return t.name==n.name&&t.message==n.message;case i:return t!=+t?n!=+n:0==t?1/t==1/n:t==+n;case c:case u:return t==n+""}return!1}var r="[object Boolean]",e="[object Date]",o="[object Error]",i="[object Number]",c="[object RegExp]",u="[object String]";t.exports=n},function(t,n,r){function e(t,n,r,e,i,u,a){var s=o(t),f=s.length,p=o(n),l=p.length;if(f!=l&&!i)return!1;for(var h,v=-1;++v<f;){var y=s[v],x=c.call(n,y);if(x){var d=t[y],b=n[y];x=void 0,e&&(x=i?e(b,d,y):e(d,b,y)),"undefined"==typeof x&&(x=d&&d===b||r(d,b,e,i,u,a))}if(!x)return!1;h||(h="constructor"==y)}if(!h){var g=t.constructor,w=n.constructor;if(g!=w&&"constructor"in t&&"constructor"in n&&!("function"==typeof g&&g instanceof g&&"function"==typeof w&&w instanceof w))return!1}return!0}var o=r(5),i=Object.prototype,c=i.hasOwnProperty;t.exports=e},function(t){function n(t,n,r){for(var e=t.length,o=r?n||e:(n||0)-1;r?o--:++o<e;){var i=t[o];if(i!==i)return o}return-1}t.exports=n},function(t){function n(t){var n=t.length,r=new t.constructor(n);return n&&"string"==typeof t[0]&&e.call(t,"index")&&(r.index=t.index,r.input=t.input),r}var r=Object.prototype,e=r.hasOwnProperty;t.exports=n},function(t,n,r){function e(t,n,r){var e=t.constructor;switch(n){case f:return o(t);case i:case c:return new e(+t);case p:case l:case h:case v:case y:case x:case d:case b:case g:var j=t.buffer;return new e(r?o(j):j,t.byteOffset,t.length);case u:case s:return new e(t);case a:var m=new e(t.source,w.exec(t));m.lastIndex=t.lastIndex}return m}var o=r(56),i="[object Boolean]",c="[object Date]",u="[object Number]",a="[object RegExp]",s="[object String]",f="[object ArrayBuffer]",p="[object Float32Array]",l="[object Float64Array]",h="[object Int8Array]",v="[object Int16Array]",y="[object Int32Array]",x="[object Uint8Array]",d="[object Uint8ClampedArray]",b="[object Uint16Array]",g="[object Uint32Array]",w=/\w*$/;t.exports=e},function(t){function n(t){var n=t.constructor;return"function"==typeof n&&n instanceof n||(n=Object),new n}t.exports=n},function(t,n,r){function e(t){var n=!(c.funcNames?t.name:c.funcDecomp);if(!n){var r=s.call(t);c.funcNames||(n=!u.test(r)),n||(n=a.test(r)||i(t),o(t,n))}return n}var o=r(53),i=r(2),c=r(16),u=/^\s*function[ \n\r\t]+\w/,a=/\bthis\b/,s=Function.prototype.toString;t.exports=e},function(t,n,r){function e(t){return t===t&&(0===t?1/t>0:!o(t))}var o=r(3);t.exports=e},function(t,n,r){(function(n){var e=r(2),o=e(o=n.WeakMap)&&o,i=o&&new o;t.exports=i}).call(n,function(){return this}())},function(t,n,r){function e(t){for(var n=a(t),r=n.length,e=r&&t.length,f=e&&u(e)&&(i(t)||s.nonEnumArgs&&o(t)),l=-1,h=[];++l<r;){var v=n[l];(f&&c(v,e)||p.call(t,v))&&h.push(v)}return h}var o=r(14),i=r(4),c=r(13),u=r(1),a=r(75),s=r(16),f=Object.prototype,p=f.hasOwnProperty;t.exports=e},function(t){function n(t,n){for(var r,e=-1,o=t.length,i=-1,c=[];++e<o;){var u=t[e],a=n?n(u,e,t):u;e&&r===a||(r=a,c[++i]=u)}return c}t.exports=n},function(t,n,r){function e(t,n,r,e){return"boolean"!=typeof n&&null!=n&&(e=r,r=c(t,n,e)?null:n,n=!1),r="function"==typeof r&&i(r,e,1),o(t,n,r)}var o=r(21),i=r(10),c=r(25);t.exports=e},function(t,n,r){function e(t){return"string"==typeof t||o(t)&&u.call(t)==i||!1}var o=r(8),i="[object String]",c=Object.prototype,u=c.toString;t.exports=e},function(t,n,r){function e(t){return i(t)&&o(t.length)&&D[T.call(t)]||!1}var o=r(1),i=r(8),c="[object Arguments]",u="[object Array]",a="[object Boolean]",s="[object Date]",f="[object Error]",p="[object Function]",l="[object Map]",h="[object Number]",v="[object Object]",y="[object RegExp]",x="[object Set]",d="[object String]",b="[object WeakMap]",g="[object ArrayBuffer]",w="[object Float32Array]",j="[object Float64Array]",m="[object Int8Array]",A="[object Int16Array]",_="[object Int32Array]",O="[object Uint8Array]",F="[object Uint8ClampedArray]",E="[object Uint16Array]",S="[object Uint32Array]",D={};D[w]=D[j]=D[m]=D[A]=D[_]=D[O]=D[F]=D[E]=D[S]=!0,D[c]=D[u]=D[g]=D[a]=D[s]=D[f]=D[p]=D[l]=D[h]=D[v]=D[y]=D[x]=D[d]=D[b]=!1;var M=Object.prototype,T=M.toString;t.exports=e},function(t,n,r){function e(t,n,r){return n=o(n,r,3),i(t,n,c,!0)}var o=r(6),i=r(44),c=r(7);t.exports=e},function(t,n,r){function e(t,n,r){return("function"!=typeof n||"undefined"!=typeof r)&&(n=i(n,r,3)),o(t,n)}var o=r(7),i=r(10);t.exports=e},function(t,n,r){function e(t){if(null==t)return[];a(t)||(t=Object(t));var n=t.length;n=n&&u(n)&&(i(t)||s.nonEnumArgs&&o(t))&&n||0;for(var r=t.constructor,e=-1,f="function"==typeof r&&r.prototype==t,l=Array(n),h=n>0;++e<n;)l[e]=e+"";for(var v in t)h&&c(v,n)||"constructor"==v&&(f||!p.call(t,v))||l.push(v);return l}var o=r(14),i=r(4),c=r(13),u=r(1),a=r(3),s=r(16),f=Object.prototype,p=f.hasOwnProperty;t.exports=e},function(t,n,r){function e(t,n,r){var e={};return n=o(n,r,3),i(t,function(t,r,o){e[r]=n(t,r,o)}),e}var o=r(6),i=r(7);t.exports=e},function(t,n,r){function e(t){return t=o(t),t&&c.test(t)?t.replace(i,"\\$&"):t}var o=r(54),i=/[.*+?^${}()|[\]\/\\]/g,c=RegExp(i.source);t.exports=e},function(t,n){var r,e,o;!function(i,c){"use strict";"object"==typeof t&&"object"==typeof t.exports?t.exports=c():(e=[],r=c,o="function"==typeof r?r.apply(n,e):r,!(void 0!==o&&(t.exports=o)))}(this,function(){"use strict";function t(t){if(!t)return!0;if(i(t)&&0===t.length)return!0;for(var n in t)if(p.call(t,n))return!1;return!0}function n(t){return f.call(t)}function r(t){return"number"==typeof t||"[object Number]"===n(t)}function e(t){return"string"==typeof t||"[object String]"===n(t)}function o(t){return"object"==typeof t&&"[object Object]"===n(t)}function i(t){return"object"==typeof t&&"number"==typeof t.length&&"[object Array]"===n(t)}function c(t){return"boolean"==typeof t||"[object Boolean]"===n(t)}function u(t){var n=parseInt(t);return n.toString()===t?n:t}function a(n,o,i,c){if(r(o)&&(o=[o]),t(o))return n;if(e(o))return a(n,o.split("."),i,c);var s=u(o[0]);if(1===o.length){var f=n[s];return void 0!==f&&c||(n[s]=i),f}return void 0===n[s]&&(n[s]=r(s)?[]:{}),a(n[s],o.slice(1),i,c)}function s(n,o){if(r(o)&&(o=[o]),t(n))return void 0;if(t(o))return n;if(e(o))return s(n,o.split("."));var c=u(o[0]),a=n[c];if(1===o.length)void 0!==a&&(i(n)?n.splice(c,1):delete n[c]);else if(void 0!==n[c])return s(n[c],o.slice(1));return n}var f=Object.prototype.toString,p=Object.prototype.hasOwnProperty,l={};return l.ensureExists=function(t,n,r){return a(t,n,r,!0)},l.set=function(t,n,r,e){return a(t,n,r,e)},l.insert=function(t,n,r,e){var o=l.get(t,n);e=~~e,i(o)||(o=[],l.set(t,n,o)),o.splice(e,0,r)},l.empty=function(n,u){if(t(u))return n;if(t(n))return void 0;var a,s;if(!(a=l.get(n,u)))return n;if(e(a))return l.set(n,u,"");if(c(a))return l.set(n,u,!1);if(r(a))return l.set(n,u,0);if(i(a))a.length=0;else{if(!o(a))return l.set(n,u,null);for(s in a)p.call(a,s)&&delete a[s]}},l.push=function(t,n){var r=l.get(t,n);i(r)||(r=[],l.set(t,n,r)),r.push.apply(r,Array.prototype.slice.call(arguments,2))},l.coalesce=function(t,n,r){for(var e,o=0,i=n.length;i>o;o++)if(void 0!==(e=l.get(t,n[o])))return e;return r},l.get=function(n,o,i){if(r(o)&&(o=[o]),t(o))return n;if(t(n))return i;if(e(o))return l.get(n,o.split("."),i);var c=u(o[0]);return 1===o.length?void 0===n[c]?i:n[c]:l.get(n[c],o.slice(1),i)},l.del=function(t,n){return s(t,n)},l})},function(t){t.exports="1.5.2"}])});
var Router = ReactRouter,
    Route = Router.Route,
    RouteHandler = Router.RouteHandler,
    Link = Router.Link,
    NotFoundRoute = Router.NotFoundRoute,
    DefaultRoute = Router.DefaultRoute;marked.setOptions({
  renderer: new marked.Renderer(),
  gfm: true,
  breaks: true,
  sanitize: true
});

var channelConstants = {
  COMMENT: {
    ADD: "COMMENT:ADD",
    LIKE: "COMMENT:LIKE",
    REMOVE: "COMMENT:REMOVE"
  },
  THOUGHT: {
    ADD: "THOUGHT:ADD",
    LIKE: "THOUGHT:LIKE",
    LOAD: "THOUGHT:LOAD",
    LOAD_MORE: "THOUGHT:LOAD_MORE",
    REMOVE: "THOUGHT:REMOVE",
    SHOW_ALL_COMMENTS: "THOUGHT:SHOW_ALL_COMMENTS"
  },
  ROUTE: {
    TRANSITION: "ROUTE:TRANSITION"
  }
};

var methods = {
  comments: {
    add: function (payload) {
      this.dispatch(channelConstants.COMMENT.ADD, {
        body: payload.body,
        thoughtId: payload.thoughtId
      });
    },

    like: function (id, oldState) {
      this.dispatch(channelConstants.COMMENT.LIKE, {
        id: id,
        oldState: oldState
      });
    },

    remove: function (id) {
      this.dispatch(channelConstants.COMMENT.REMOVE, id);
    }
  },

  thoughts: {
    add: function (body) {
      this.dispatch(channelConstants.THOUGHT.ADD, {
        body: body
      });
    },

    like: function (id, oldState) {
      this.dispatch(channelConstants.THOUGHT.LIKE, {
        id: id,
        oldState: oldState
      });
    },

    load: function (data) {
      this.dispatch(channelConstants.THOUGHT.LOAD, data);
    },

    loadMore: function (data) {
      this.dispatch(channelConstants.THOUGHT.LOAD_MORE, data);
    },

    remove: function (id) {
      this.dispatch(channelConstants.THOUGHT.REMOVE, id);
    },

    showAllComments: function (id) {
      this.dispatch(channelConstants.THOUGHT.SHOW_ALL_COMMENTS, id);
    }
  },

  routes: {
    transition: function (path, params) {
      this.dispatch(c.ROUTE.TRANSITION, { path: path, params: params });
    }
  }
};

var actions = {
  methods: methods,
  constants: channelConstants
};

var NOT_FOUND_TOKEN = {};

var CommentStore = Fluxxor.createStore({
  initialize: function () {
    this.commentId = 0;
    this.comments = {};

    this.bindActions(actions.constants.COMMENT.ADD, this.handleAddComment, actions.constants.COMMENT.LIKE, this.handleLikeComment, actions.constants.COMMENT.REMOVE, this.handleRemoveComment);
  },

  getComment: function (id) {
    return this.comments[id] || NOT_FOUND_TOKEN;
  },

  prepareComments: function (comments, hash) {
    comments = comments || {};
    for (var i = 0; i < comments.length; ++i) {
      var comment = comments[i];
      comment.user = this.flux.store('user').getUser(comment.user_id);
      hash[comment.id] = comment;
    }
    this.comments = hash;
    this.emit('change');
  },

  setComments: function (comments) {
    this.prepareComments(comments, {});
  },

  addComments: function (comments) {
    this.prepareComments(comments, this.comments);
  },

  prepareNewComment: function (body, thoughtId) {
    comment = {
      body: marked(body),
      timestamp: Date.now() / 1000,
      liked: false,
      own: true,
      deleted: false,
      commentable_id: thoughtId,
      likes: {
        count: 0,
        likers: []
      }
    };
    comment.id = 'tmpCommentId' + this.commentId; // arbitrary so it gets at the top
    comment.user = user_data; // has to be defined in the DOM
    return comment;
  },

  handleAddComment: function (payload) {
    var body = payload.body;
    var thoughtId = payload.thoughtId;
    var comment = this.prepareNewComment(body, thoughtId);
    var tmpId = comment.id;
    this.comments[tmpId] = comment;
    this.flux.store('thought').addCommentId(comment.commentable_id, tmpId);
    this.flux.store('thought').emit('change');

    $.ajax({
      url: '/api/v1/comments',
      dataType: 'json',
      type: 'POST',
      data: { thought_id: thoughtId, comment: { raw_body: body } },
      success: (function (data) {
        var newComment = this.comments[tmpId];
        newComment.id = data.comment.id;
        newComment.body = data.comment.body;
        this.comments[newComment.id] = newComment;
        this.flux.store('thought').addCommentId(comment.commentable_id, newComment.id);
        this.flux.store('thought').removeCommentId(comment.commentable_id, tmpId);
        delete this.comments[tmpId];
      }).bind(this),
      error: (function (xhr, status, err) {
        console.error('cant add', status, err.toString());
        this.flux.store('thought').removeCommentId(comment.commentable_id, tmpId);
        delete this.comments[comment.id];
      }).bind(this),
      complete: (function () {
        this.flux.store('thought').emit('change');
      }).bind(this)
    });
  },

  handleLikeComment: function (payload) {
    var oldState = payload.oldState;
    var action = oldState ? 'DELETE' : 'POST';
    var comment = this.comments[payload.id];
    var count = oldState ? -1 : 1;

    comment.liked = !oldState;
    comment.likes.count += count;
    this.flux.store('thought').emit('change');

    $.ajax({
      url: '/api/v1/likes',
      dataType: 'json',
      type: action,
      data: { comment_id: comment.id },
      success: (function (data) {
        comment.liked = data.liked;
      }).bind(this),
      error: (function (xhr, status, err) {
        comment.liked = oldState;
        comment.likes.count -= count;
      }).bind(this),
      complete: (function () {
        this.flux.store('thought').emit('change');
      }).bind(this)
    });
  },

  handleRemoveComment: function (id) {
    var comment = this.comments[id];
    comment.deleted = true;
    this.flux.store('thought').emit('change');

    $.ajax({
      url: '/api/v1/comments/' + id,
      dataType: 'json',
      type: 'DELETE',
      success: (function (data) {
        this.flux.store('thought').removeCommentId(comment.commentable_id, id);
        delete this.comments[id];
      }).bind(this),
      error: (function (xhr, status, err) {
        comment.deleted = false;
        console.error('error deleting', status, err.toString());
      }).bind(this),
      complete: (function () {
        this.flux.store('thought').emit('change');
      }).bind(this)
    });
  }
});

var ThoughtStore = Fluxxor.createStore({
  initialize: function () {
    this.thoughtId = 0;
    this.thoughts = {};
    this.currentData = null;

    this.bindActions(actions.constants.THOUGHT.ADD, this.handleAddThought, actions.constants.THOUGHT.LIKE, this.handleLikeThought, actions.constants.THOUGHT.LOAD, this.handleLoadThoughts, actions.constants.THOUGHT.LOAD_MORE, this.handleLoadMoreThoughts, actions.constants.THOUGHT.REMOVE, this.handleRemoveThought, actions.constants.THOUGHT.SHOW_ALL_COMMENTS, this.handleShowAllComments);
  },

  getThoughts: function (data) {
    data = data || {};

    if (!this.currentData || data['hashtag'] != this.currentData['hashtag']) {
      this.handleLoadThoughts(data);
      this.currentData = data;
    }

    var thoughts = Object.keys(this.thoughts).reverse().map((function (key) {
      var t = this.thoughts[key];
      return this.populateThought(t);
    }).bind(this));

    return {
      thoughts: thoughts,
      nextPage: this.nextPage,
      loading: this.loading
    };
  },

  getThought: function (id) {
    var thought = this.thoughts[id];
    if (thought) {
      return this.populateThought(thought);
    }

    this.loadThought(id);

    return NOT_FOUND_TOKEN;
  },

  populateThought: function (thought) {
    thought.comments = [];
    thought.comment_ids.forEach(function (id) {
      var comment = this.flux.store('comment').getComment(id);
      if (comment) thought.comments.push(comment);
    });
    thought.user = this.flux.store('user').getUser(thought.user_id);
    return thought;
  },

  prepareThoughts: function (thoughts, hash) {
    for (var i = 0; i < thoughts.length; ++i) {
      var thought = thoughts[i];
      hash[thought.id] = thought;
    }

    this.thoughts = hash;
    this.emit('change');
  },

  setThoughts: function (thoughts) {
    this.prepareThoughts(thoughts, {});
  },

  addThoughts: function (thoughts) {
    this.prepareThoughts(thoughts, this.thoughts);
  },

  prepareNewThought: function (body) {
    thought = {
      body: marked(body),
      timestamp: Date.now() / 1000,
      liked: false,
      own: true,
      deleted: false,
      comment_ids: [],
      likes: {
        count: 0,
        likers: []
      },
      showAllComments: false,
      link_data: {},
      user_id: user_data.id // has to be defined in the DOM
    };
    thought.id = Math.max.apply(Math, Object.keys(this.thoughts)) + 1000; // arbitrary so it gets at the top
    thought.user = user_data;
    return thought;
  },

  loadThought: function (id) {
    $.ajax({
      url: '/api/v1/thoughts/' + id,
      dataType: 'json',
      type: 'GET',
      success: (function (data) {
        this.flux.store('user').setUsers(data.users);
        this.flux.store('comment').setComments(data.comments);
        this.thoughts[data.thought.id] = data.thought;
        // this.setThoughts({ thoughts: [data.thought] });
        this.emit("change");
      }).bind(this),
      error: (function (xhr, status, err) {
        console.error('cant load', status, err.toString());
      }).bind(this),
      complete: (function () {}).bind(this)
    });
  },

  handleShowAllComments: function (id) {
    var thought = this.thoughts[id];
    thought.showAllComments = true;
    this.emit('change');
  },

  handleLoadThoughts: function (data) {
    this.loading = true;
    this.emit('change');

    $.ajax({
      url: 'api/v1/thoughts',
      data: data,
      dataType: 'json',
      type: 'GET',
      success: (function (data) {
        this.flux.store('user').setUsers(data.users);
        this.flux.store('comment').setComments(data.comments);
        this.nextPage = data.meta.next_page;
        this.setThoughts(data.thoughts);
      }).bind(this),
      error: (function (xhr, status, err) {
        console.error('cant load', status, err.toString());
      }).bind(this),
      complete: (function () {
        this.loading = false;
        this.emit('change');
      }).bind(this)
    });
  },

  handleLoadMoreThoughts: function (data) {
    this.loading = true;
    this.emit('change');

    $.ajax({
      url: 'api/v1/thoughts',
      data: data,
      dataType: 'json',
      type: 'GET',
      success: (function (data) {
        this.flux.store('user').addUsers(data.users);
        this.flux.store('comment').addComments(data.comments);
        this.nextPage = data.meta.next_page;
        this.addThoughts(data.thoughts);
      }).bind(this),
      error: (function (xhr, status, err) {
        console.error('cant load', status, err.toString());
      }).bind(this),
      complete: (function () {
        this.loading = false;
        this.emit('change');
      }).bind(this)
    });
  },

  addCommentId: function (id, commentId) {
    var thought = this.thoughts[id];
    thought.comment_ids.push(commentId);
  },

  removeCommentId: function (id, commentId) {
    var thought = this.thoughts[id];
    var i = thought.comment_ids.indexOf(commentId);
    thought.comment_ids.splice(i, 1);
  },

  handleAddThought: function (payload) {
    var body = payload.body;
    var thought = this.prepareNewThought(body);
    var tmpId = thought.id;
    this.thoughts[tmpId] = thought;
    this.emit('change');

    $.ajax({
      url: '/api/v1/thoughts',
      dataType: 'json',
      type: 'POST',
      data: { thought: { raw_body: body } },
      success: (function (data) {
        this.thoughts[data.thought.id] = data.thought;
        delete this.thoughts[tmpId];
      }).bind(this),
      error: (function (xhr, status, err) {
        console.error('cant add', status, err.toString());
        delete this.thoughts[thought.id];
      }).bind(this),
      complete: (function () {
        this.emit("change");
      }).bind(this)
    });
  },

  handleLikeThought: function (payload) {
    var oldState = payload.oldState;
    var action = oldState ? 'DELETE' : 'POST';
    var count = oldState ? -1 : 1;
    var thought = this.thoughts[payload.id];

    thought.liked = !oldState;
    thought.likes.count += count;
    this.emit('change');

    $.ajax({
      url: '/api/v1/likes',
      dataType: 'json',
      type: action,
      data: { thought_id: thought.id },
      success: (function (data) {
        thought.liked = data.liked;
      }).bind(this),
      error: (function (xhr, status, err) {
        thought.liked = oldState;
        thought.likes.count -= count;
      }).bind(this),
      complete: (function () {
        this.emit("change");
      }).bind(this)
    });
  },

  handleRemoveThought: function (id) {
    var thought = this.thoughts[id];
    thought.deleted = true;
    this.emit('change');

    $.ajax({
      url: '/api/v1/thoughts/' + id,
      dataType: 'json',
      type: 'DELETE',
      success: (function (data) {
        delete this.thoughts[id];
      }).bind(this),
      error: (function (xhr, status, err) {
        thought.deleted = false;
        console.error('error deleting', status, err.toString());
      }).bind(this),
      complete: (function () {
        this.emit("change");
      }).bind(this)
    });
  }
});

var UserStore = Fluxxor.createStore({
  initialize: function () {
    this.users = {};
  },

  getUser: function (id) {
    return this.users[id] || NOT_FOUND_TOKEN;
  },

  prepareUsers: function (users, hash) {
    users = users || {};
    for (var i = 0; i < users.length; ++i) {
      var user = users[i];
      hash[user.id] = user;
    }
    hash[user_data.id] = user_data;

    this.users = hash;
    this.emit('change');
  },

  setUsers: function (users) {
    this.prepareUsers(users, {});
  },

  addUsers: function (users) {
    this.prepareUsers(users, this.users);
  }
});

var RouteStore = Fluxxor.createStore({
  initialize: function (options) {
    this.router = options.router;

    this.bindActions(actions.constants.ROUTE.TRANSITION, this.handleRouteTransition);
  },

  handleRouteTransition: function (payload) {
    var path = payload.path,
        params = payload.params;

    this.router.transitionTo(path, params);
  }
});

ThoughtStore.NOT_FOUND_TOKEN = NOT_FOUND_TOKEN;// utils
function arrayToSentence(array) {
  var output = '';
  array.forEach(function (val, i) {
    if (i + 2 < array.length) {
      output += val + ', ';
    } else if (i + 2 == array.length) {
      output += val + ' and ';
    } else {
      output += val;
    }
  });
  return output;
}

var FluxMixin = Fluxxor.FluxMixin(React),
    StoreWatchMixin = Fluxxor.StoreWatchMixin;

var DateComponent = React.createClass({
  displayName: 'DateComponent',

  componentDidMount: function () {
    this.refresh();
  },

  refresh: function () {
    if (!this.isMounted()) return;

    var period = 10000;

    var now = Date.now() / 1000;
    var seconds = Math.round(Math.abs(this.props.timestamp - now));

    // refresh periods match momentjs
    if (seconds < 90) {
      period = 30 * 1000; // 30 secs
    } else if (seconds < 45 * 60) {
        // 45 mins
        period = 60 * 1000; // 60 secs
      } else if (seconds < 90 * 60) {
          // 90 mins
          period = 30 * 60 * 1000; // 30 mins
        } else if (seconds < 22 * 60 * 60) {
            // 22 hours
            period = 60 * 60 * 1000; // 1 hour
          } else if (seconds < 25 * 60 * 60 * 24) {
              // 25 days
              period = 24 * 60 * 60 * 1000; // 1 day
            } else {
                period = 0;
              }

    if (!period) return;

    var _ = this;
    var timer = window.setTimeout(function () {
      _.forceUpdate();
      _.refresh();
    }, period);

    this.setState({ timer: timer }); // so we can clear it when unmounting
  },

  componentWillUnmount: function () {
    if (this.state && this.state.timer) window.clearTimeout(this.state.timer);
  },

  render: function () {
    var date = moment.unix(this.props.timestamp).fromNow();

    return React.createElement(
      'span',
      null,
      date
    );
  }
});

var LinkData = React.createClass({
  displayName: 'LinkData',

  render: function () {
    var data = this.props.data;
    if (data.image_link) var img = React.createElement('img', { className: 'media-object', src: data.image_link });

    if (this.props.link) {
      return React.createElement(
        'a',
        { className: 'thought-link', href: this.props.link, target: '_blank' },
        React.createElement(
          'div',
          { className: 'media' },
          React.createElement(
            'div',
            { className: 'media-body' },
            React.createElement(
              'div',
              { className: 'thought-link-inner' },
              React.createElement(
                'h5',
                { className: 'media-heading' },
                data.title
              ),
              React.createElement(
                'p',
                { className: 'description' },
                data.description
              ),
              React.createElement(
                'p',
                { className: 'website' },
                data.website_name
              )
            )
          ),
          React.createElement(
            'div',
            { className: 'media-right' },
            img
          )
        )
      );
    } else {
      return React.createElement('div', null);
    }
  }
});

var Like = React.createClass({
  displayName: 'Like',

  handleClick: function (e) {
    e.preventDefault();

    var oldState = this.props.liked;
    this.props.onButtonClick(oldState);
  },

  render: function () {
    var text = this.props.liked ? 'Liked' : 'Like';

    return React.createElement(
      'a',
      { href: '', onClick: this.handleClick },
      text
    );
  }
});

var BodyContainer = React.createClass({
  displayName: 'BodyContainer',

  componentDidMount: function () {
    var body = $(this.refs.bodyContainer.getDOMNode());
    var height = body.height();
    if (height > this.props.maxHeight) {
      body.data('orig-height', height);
      body.addClass('collapsed');
    }
  },
  componentDidUpdate: function (prevProps) {
    if (prevProps.body != this.props.body) {
      var body = $(this.refs.bodyContainer.getDOMNode());
      body.css('height', '');
      body.removeClass('collapsed');
      var height = body.height();
      if (height > this.props.maxHeight) {
        body.data('orig-height', height);
        body.addClass('collapsed');
      }
    }
  },

  expand: function (e) {
    e.preventDefault();

    var body = $(this.refs.bodyContainer.getDOMNode());
    var height = body.data('orig-height');
    body.animate({ height: height }, 150, function () {
      $(this).removeClass('collapsed');
    });
  },

  render: function () {
    return React.createElement(
      'div',
      { className: 'body-container', ref: 'bodyContainer' },
      React.createElement('div', { className: 'body', dangerouslySetInnerHTML: { __html: this.props.body } }),
      React.createElement(
        'a',
        { className: 'expand', onClick: this.expand },
        'See more...'
      )
    );
  }
});var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var CommentForm = React.createClass({
  displayName: 'CommentForm',

  getInitialState: function () {
    return {
      submitVisibility: 'hidden'
    };
  },

  focus: function (e) {
    this.refs.body.getDOMNode().focus();
  },

  componentDidMount: function () {
    var body = $(this.refs.body.getDOMNode());

    body.on('keypress', this.handleKeypress);

    // auto adjust the height of the textarea
    body.on('keyup keydown', function () {
      var t = $(this);
      var h = t[0].scrollHeight - parseInt(t.css('padding-top')) - parseInt(t.css('padding-bottom'));
      t.height(21).height(h); // where 21 is the minimum height of textarea (25 - 4 for padding)
    });

    body.tooltip({
      title: 'Press Enter to submit. Shift+Enter for a new line.',
      placement: 'top',
      trigger: 'focus',
      container: 'body'
    });
  },

  componentWillUnmount: function () {
    var body = $(this.refs.body.getDOMNode());
    body.off('focus blur keyup keypress keydown');
  },

  handleKeypress: function (e) {
    if (e.which == 13 && !e.shiftKey) {
      this.handleSubmit(e);
    }
  },

  handleSubmit: function (e) {
    e.preventDefault();

    var body = this.refs.body.getDOMNode().value.trim();
    if (!body) return;

    this.props.onCommentSubmit(body);
    this.refs.body.getDOMNode().value = '';
    $(this.refs.body.getDOMNode()).css('height', '').tooltip('hide');
    this.getDOMNode().focus();
  },

  render: function () {
    var classes = ['comment-form'];

    return React.createElement(
      'form',
      { ref: 'form', className: classes.join(' '), onSubmit: this.handleSubmit },
      React.createElement('img', { className: 'img-rounded', src: user_data.avatar_url }),
      React.createElement(
        'div',
        { className: 'textarea-container' },
        React.createElement('textarea', { ref: 'body', placeholder: 'Type your comment' })
      )
    );
  }
});

var LikesCount = React.createClass({
  displayName: 'LikesCount',

  render: function () {
    if (this.props.likes.count) {
      return React.createElement(
        'span',
        null,
        React.createElement(
          'span',
          { className: 'separator' },
          '•'
        ),
        React.createElement(
          'span',
          null,
          this.props.likes.count,
          React.createElement('i', { className: 'fa fa-thumbs-o-up' })
        )
      );
    } else {
      return React.createElement('div', null);
    }
  }
});

var Comment = React.createClass({
  displayName: 'Comment',

  mixins: [FluxMixin],

  handleDelete: function (e) {
    e.preventDefault();

    this.getFlux().actions.comments.remove(this.props.id);
  },

  handleLike: function (oldState) {
    this.getFlux().actions.comments.like(this.props.id, oldState);
  },

  render: function () {
    var idName = 'comment-' + this.props.id;
    var user = this.props.user;
    if (this.props.own) {
      var actions = React.createElement(
        'span',
        null,
        React.createElement(
          'a',
          { href: '', onClick: this.handleDelete },
          'Delete'
        ),
        React.createElement(
          'span',
          { className: 'separator' },
          '•'
        )
      );
    }
    var classes = ['comment'];
    if (this.props.deleted) classes.push('deleted');

    // <span className="separator">&bull;</span>
    // <a href=''>Mention</a>

    return React.createElement(
      'div',
      { id: idName, className: classes.join(' ') },
      React.createElement(
        'div',
        { className: 'media' },
        React.createElement(
          'div',
          { className: 'media-left' },
          React.createElement(
            'a',
            { href: user.url },
            React.createElement('img', { className: 'media-object img-rounded', src: user.avatar_url })
          )
        ),
        React.createElement(
          'div',
          { className: 'media-body' },
          React.createElement(
            'p',
            { className: 'user' },
            React.createElement(
              'a',
              { href: user.url },
              user.name
            )
          ),
          React.createElement(BodyContainer, { body: this.props.body, maxHeight: '130' }),
          React.createElement(
            'div',
            { className: 'actions' },
            React.createElement(
              'span',
              { className: 'time-created' },
              React.createElement(DateComponent, { timestamp: this.props.timestamp })
            ),
            React.createElement(
              'span',
              { className: 'separator' },
              '•'
            ),
            actions,
            React.createElement(Like, { liked: this.props.liked, onButtonClick: this.handleLike }),
            React.createElement(LikesCount, { likes: this.props.likes })
          )
        )
      )
    );
  }
});

var CommentList = React.createClass({
  displayName: 'CommentList',

  render: function () {
    var commentNodes = this.props.comments.map(function (comment, index) {
      return React.createElement(Comment, _extends({}, comment, { key: index }));
    });
    return React.createElement(
      'div',
      { className: 'comment-list' },
      commentNodes
    );
  }
});

var CommentContainer = React.createClass({
  displayName: 'CommentContainer',

  mixins: [FluxMixin],

  focusForm: function () {
    this.refs.commentForm.focus();
  },

  handleCommentSubmit: function (body, thoughtId) {
    this.getFlux().actions.comments.add({ body: body, thoughtId: this.props.thoughtId });
  },

  handleShowAll: function (e) {
    e.preventDefault();
    this.props.showAllComments(this.props.thoughtId);
  },

  render: function () {
    var more = '';
    if (this.props.moreCommentsCount) {
      more = React.createElement(
        'div',
        { className: 'thought-comments-more' },
        React.createElement(
          'a',
          { href: '#', onClick: this.handleShowAll },
          'Show earlier comments (',
          this.props.moreCommentsCount,
          ')'
        )
      );
    }

    return React.createElement(
      'div',
      { className: 'comment-container' },
      more,
      React.createElement(CommentList, { comments: this.props.comments }),
      React.createElement(CommentForm, { ref: 'commentForm', onCommentSubmit: this.handleCommentSubmit })
    );
  }
});var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var ThoughtForm = React.createClass({
  displayName: 'ThoughtForm',

  componentDidMount: function () {
    $(this.refs.md.getDOMNode()).tooltip({
      title: 'Markdown supported!'
    });

    // auto adjust the height of the textarea
    $(this.refs.body.getDOMNode()).on('keyup keydown', function () {
      var t = $(this);
      var h = t[0].scrollHeight - parseInt(t.css('padding-top')) - parseInt(t.css('padding-bottom'));
      t.height(50).height(h); // where 21 is the minimum height of textarea (64 - 14 for padding)
    });

    $(this.refs.body.getDOMNode()).on('keyup', this.showFeedback);
  },

  componentWillUnmount: function () {
    var body = $(this.refs.body.getDOMNode());
    body.off('keyup keydown');

    $(this.refs.md.getDOMNode()).tooltip('destroy');
  },

  showFeedback: function (e) {
    var bodyVal = this.refs.body.getDOMNode().value;
    var match = null;
    if (bodyVal) match = bodyVal.match(/(^|\s)(#[a-z\d]+)/ig);
    var feedback = $(this.refs.feedback.getDOMNode());
    if (bodyVal && !match) {
      feedback.html("Don't forget to add one or more hashtags to categorize your post! For instance: #arduino, <a href='http://onlineslangdictionary.com/meaning-definition-of/wip' target='_blank' tabIndex='-1'>#WIP</a>, #feedback.<br>Posts without a hashtag can only be found on the public channel.");
    } else {
      feedback.html('');
    }
  },

  handleSubmit: function (e) {
    e.preventDefault();

    this.refs.submit.getDOMNode().blur();

    var textarea = this.refs.body.getDOMNode();
    var body = textarea.value.trim();
    if (!body) {
      return;
    }
    this.props.onThoughtSubmit(body);
    textarea.value = '';
    this.showFeedback();
    $(textarea).css('height', '');
  },

  render: function () {
    return React.createElement(
      'form',
      { className: 'thought-form', onSubmit: this.handleSubmit },
      React.createElement(
        'div',
        { className: 'textarea-container' },
        React.createElement('textarea', { ref: 'body', placeholder: 'Share something interesting or ask a question.' })
      ),
      React.createElement(
        'div',
        { className: 'submit-container' },
        React.createElement('div', { ref: 'feedback', className: 'feedback' }),
        React.createElement(
          'a',
          { tabIndex: '-1', ref: 'md', className: 'markdown-supported', href: 'https://help.github.com/articles/github-flavored-markdown/', target: '_blank' },
          React.createElement('img', { src: '/assets/markdown-mark.png' })
        ),
        React.createElement('input', { ref: 'submit', className: 'btn btn-primary', type: 'submit', value: 'Post' })
      )
    );
  }
});

var Thought = React.createClass({
  displayName: 'Thought',

  mixins: [FluxMixin],

  handleComment: function (e) {
    e.preventDefault();

    this.props.onCommentClick();
  },

  handleDelete: function (e) {
    e.preventDefault();

    this.getFlux().actions.thoughts.remove(this.props.id);
  },

  handleLike: function (oldState) {
    this.getFlux().actions.thoughts.like(this.props.id, oldState);
  },

  render: function () {
    var user = this.props.user;
    if (this.props.own) {
      var actions = React.createElement(
        'span',
        null,
        React.createElement(
          'a',
          { href: '', onClick: this.handleDelete },
          'Delete'
        ),
        React.createElement(
          'span',
          { className: 'separator' },
          '•'
        )
      );
    } else {
      var flag = React.createElement(
        'span',
        { className: 'default-hidden' },
        React.createElement(
          'span',
          { className: 'separator' },
          '•'
        ),
        React.createElement(FlagButton, { flaggable: { id: this.props.id, type: 'Thought' } })
      );
    }

    return React.createElement(
      'div',
      { className: 'thought' },
      React.createElement(
        'div',
        { className: 'media' },
        React.createElement(
          'div',
          { className: 'media-left' },
          React.createElement(
            'a',
            { href: user.url },
            React.createElement('img', { className: 'media-object img-rounded', src: user.avatar_url })
          )
        ),
        React.createElement(
          'div',
          { className: 'media-body' },
          React.createElement(
            'h4',
            { className: 'user media-heading' },
            React.createElement(
              'a',
              { href: user.url },
              user.name
            )
          ),
          React.createElement(
            'p',
            { className: 'time-created' },
            React.createElement(
              Link,
              { to: 'thought', params: { id: this.props.id } },
              React.createElement(DateComponent, { timestamp: this.props.timestamp })
            )
          )
        )
      ),
      React.createElement(BodyContainer, { body: this.props.body, maxHeight: '300' }),
      React.createElement(LinkData, { link: this.props.link, data: this.props.link_data }),
      React.createElement(
        'div',
        { className: 'actions' },
        actions,
        React.createElement(Like, { liked: this.props.liked, onButtonClick: this.handleLike }),
        React.createElement(
          'span',
          { className: 'separator' },
          '•'
        ),
        React.createElement(
          'a',
          { href: '', onClick: this.handleComment },
          'Comment'
        ),
        flag
      )
    );
  }
});

var ThoughtLikes = React.createClass({
  displayName: 'ThoughtLikes',

  render: function () {
    var likes = this.props.likes;
    var liked = this.props.liked;
    var nameList = [];
    if (liked) nameList.push('You');
    likes.likers.map(function (liker) {
      nameList.push("<a href='" + liker.url + "'>" + liker.name + "</a>");
    });
    var others = 0;
    if (liked) {
      others = likes.count - 3;
    } else {
      others = likes.count - 2;
    }
    if (others > 0) {
      var othersAdj = others == 1 ? 'other' : 'others';
      nameList.push(others + ' ' + othersAdj);
    }
    var verb = nameList.length == 1 && !liked ? 'likes' : 'like';
    var content = arrayToSentence(nameList) + ' ' + verb + ' this.';

    if (likes.count) {
      return React.createElement('div', { className: 'likes-container', dangerouslySetInnerHTML: { __html: content } });
    } else {
      return React.createElement('div', null);
    }
  }
});

var ThoughtContainer = React.createClass({
  displayName: 'ThoughtContainer',

  mixins: [FluxMixin],

  handleComment: function () {
    window.thoughtContainer = this;
    this.refs.commentContainer.focusForm();
  },

  showAllComments: function (id) {
    this.getFlux().actions.thoughts.showAllComments(id);
  },

  render: function () {
    var thought = this.props.thought;

    var classes = ['thought-container'];
    if (thought.deleted) classes.push('deleted');

    if (thought.comments.length <= 3 || thought.showAllComments) {
      var comments = thought.comments;
      var moreCommentsCount = 0;
    } else {
      var comments = thought.comments.slice(Math.max(thought.comments.length - 3, 1));
      var moreCommentsCount = thought.comments.length - 3;
    }

    return React.createElement(
      'div',
      { className: classes.join(' ') },
      React.createElement(Thought, _extends({}, thought, { onCommentClick: this.handleComment })),
      React.createElement(ThoughtLikes, { likes: thought.likes, liked: thought.liked }),
      React.createElement(CommentContainer, { ref: 'commentContainer', thoughtId: thought.id, comments: comments, moreCommentsCount: moreCommentsCount, showAllComments: this.showAllComments })
    );
  }
});

var ThoughtList = React.createClass({
  displayName: 'ThoughtList',

  render: function () {
    var thoughtNodes = this.props.thoughts.map(function (thought, index) {
      return React.createElement(ThoughtContainer, { thought: thought, key: thought.id });
    });
    return React.createElement(
      'div',
      { className: 'thought-list' },
      thoughtNodes
    );
  }
});

var ThoughtPage = React.createClass({
  displayName: 'ThoughtPage',

  mixins: [FluxMixin, StoreWatchMixin("thought")],

  contextTypes: {
    router: React.PropTypes.func
  },

  getStateFromFlux: function () {
    var params = this.context.router.getCurrentParams();

    return {
      thought: this.getFlux().store("thought").getThought(params.id)
    };
  },

  componentWillReceiveProps: function (nextProps) {
    this.setState(this.getStateFromFlux());
  },

  render: function () {
    var thought = this.state.thought;

    if (thought === ThoughtStore.NOT_FOUND_TOKEN) {
      return this.renderNotFound();
    }

    return this.renderWithLayout(React.createElement(ThoughtContainer, { thought: thought }));
  },

  renderNotFound: function () {
    return this.renderWithLayout(React.createElement(
      'div',
      null,
      'That thought was not found.'
    ));
  },

  renderWithLayout: function (content) {
    return React.createElement(
      'div',
      null,
      React.createElement(
        Link,
        { to: 'home' },
        '← Go back to the feed'
      ),
      React.createElement('hr', null),
      content
    );
  }
});var ChannelHeader = React.createClass({
  displayName: "ChannelHeader",

  render: function () {
    return React.createElement(
      "div",
      { className: "channel-header" },
      React.createElement(
        "h1",
        null,
        this.props.title
      )
    );
  }
});

var ChannelContainer = React.createClass({
  displayName: "ChannelContainer",

  mixins: [FluxMixin, StoreWatchMixin("thought")],

  contextTypes: {
    router: React.PropTypes.func
  },

  getStateFromFlux: function () {
    var params = this.context.router.getCurrentParams();
    var data = {};
    if (params.hashtag) data['hashtag'] = params.hashtag;

    return this.getFlux().store("thought").getThoughts(data);
  },

  componentWillReceiveProps: function (nextProps) {
    this.setState(this.getStateFromFlux());
  },

  handleThoughtSubmit: function (body) {
    this.getFlux().actions.thoughts.add(body);
  },

  handleLoadMoreThoughts: function (e) {
    e.preventDefault();
    this.setState({ loading: true });
    var data = { page: this.state.nextPage };
    var params = this.context.router.getCurrentParams();
    if (params.hashtag) data['hashtag'] = params.hashtag;
    this.getFlux().actions.thoughts.loadMore(data);
  },

  componentDidMount: function () {
    window.addEventListener('scroll', this.handleScroll);
  },

  componentWillUnmount: function () {
    window.removeEventListener('scroll', this.handleScroll);
  },

  handleScroll: function (e) {
    if ($('.load-more').length && $(window).scrollTop() > $(document).height() - $(window).height() - 1000) {
      this.handleLoadMoreThoughts(e);
    }
  },

  render: function () {
    var params = this.context.router.getCurrentParams();

    var title = 'Public feed';
    if (params.hashtag) title = '#' + params.hashtag + ' channel';

    var loadMoreButton = '';
    if (this.state.loading) {
      loadMoreButton = React.createElement(
        "div",
        { className: "text-center" },
        React.createElement("i", { className: "fa fa-spin fa-spinner fa-3x" })
      );
    } else if (this.state.nextPage) {
      loadMoreButton = React.createElement(
        "a",
        { href: "#", className: "btn btn-block btn-default load-more", onClick: this.handleLoadMoreThoughts },
        "Load more"
      );
    }

    return React.createElement(
      "div",
      { className: "channel-container" },
      React.createElement(ChannelHeader, { title: title }),
      React.createElement(ThoughtForm, { onThoughtSubmit: this.handleThoughtSubmit }),
      React.createElement(ThoughtList, { thoughts: this.state.thoughts }),
      loadMoreButton
    );
  }
});var EmptyView = React.createClass({
  displayName: "EmptyView",

  render: function () {
    return React.createElement(RouteHandler, this.props);
  }
});

var NotFound = React.createClass({
  displayName: "NotFound",

  render: function () {
    return React.createElement(
      "div",
      null,
      "Nothing to see here."
    );
  }
});var routes = React.createElement(
  Route,
  { handler: EmptyView, name: "home", path: "/" },
  React.createElement(Route, { handler: ThoughtPage, name: "thought", path: "posts/:id" }),
  React.createElement(Route, { handler: ChannelContainer, name: "hashtag", path: "/hashtags/:hashtag" }),
  React.createElement(DefaultRoute, { handler: ChannelContainer }),
  React.createElement(NotFoundRoute, { handler: NotFound })
);var router = Router.create({
  //   location: Router.HistoryLocation,
  routes: routes
});

var stores = {
  comment: new CommentStore(),
  route: new RouteStore({ router: router }),
  thought: new ThoughtStore(),
  user: new UserStore()
};

var flux = new Fluxxor.Flux(stores, actions.methods);
// flux.on("dispatch", function(type, payload) {
// console.log("Dispatch:", type, payload);
// });

router.run(function (Handler) {
  React.render(React.createElement(Handler, { flux: flux }), document.getElementById('react-container'));
});