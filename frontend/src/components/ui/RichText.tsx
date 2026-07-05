import React from 'react';
import emoji from 'react-easy-emoji';

interface RichTextProps {
  text: string;
  className?: string;
}

export function RichText({ text, className }: RichTextProps) {
  if (!text) return null;
  
  const parsed = emoji(text, {
    baseUrl: 'https://cdn.jsdelivr.net/npm/emoji-datasource-apple/img/apple/64/',
    ext: '.png',
    props: {
      className: 'inline-block w-[1.2em] h-[1.2em] align-text-bottom mx-[0.05em]',
    }
  });

  return (
    <span className={className}>
      {parsed}
    </span>
  );
}
