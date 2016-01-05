import MarkdownIt from 'markdown-it';
import emoji from 'markdown-it-emoji';
import hljs from 'markdown-it-highlightjs';

const markdown = new MarkdownIt({
    breaks: true,
    linkify: true,
    xhtmlOut: true
  })
  .use(emoji)
  .use(hljs)
  .disable([ 'image', 'heading' ]);

export default markdown