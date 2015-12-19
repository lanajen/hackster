import MarkdownIt from 'markdown-it';
import emoji from 'markdown-it-emoji';

const markdown = new MarkdownIt({
    breaks: true,
    linkify: true,
    xhtmlOut: true
  })
  .use(emoji)
  .disable([ 'image', 'heading', 'code' ]);

export default markdown