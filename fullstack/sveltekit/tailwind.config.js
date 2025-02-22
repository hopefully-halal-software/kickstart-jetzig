// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
import forms from '@tailwindcss/forms';

import { skeleton, contentPath } from '@skeletonlabs/skeleton/plugin';
import * as themes from '@skeletonlabs/skeleton/themes';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{html,js,svelte,ts}',
    contentPath(import.meta.url, 'svelte'),
  ],

  theme: {
    extend: {}
  },

  plugins: [
    forms,
    skeleton({
      // NOTE: each theme included will increase the size of your CSS bundle
      themes: [ themes.cerberus, themes.rose ]
    }),
  ]
};
