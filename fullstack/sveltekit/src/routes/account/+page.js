// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

import { goto } from '$app/navigation';
import { global } from '$lib/shared.svelte';

// In a SvelteKit + Svelte file (e.g., +page.js or +layout.js)
export async function load({ url }) {
  if(global.user) return {
    user: global.user,
  };

  const response = await window.fetch('/api/v1/account/info.json');
  
  if (!response.ok) {
    if (401 === response.status && window.location.pathname === '/account') {
      goto('/account/login');
      return;
    }
    throw new Error('Failed to fetch account information');
  }

  const data = await response.json();

  // Assuming the structure of the response looks like this:
  global.user = data.user;

  return {
    user: global.user,
  };
}
