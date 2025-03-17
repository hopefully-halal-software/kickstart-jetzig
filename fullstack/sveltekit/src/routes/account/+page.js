// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

import { toast } from 'svelte-sonner';
import { goto } from '$app/navigation';
import { error } from '@sveltejs/kit';
import { global, fetchUser } from '$lib/shared.svelte';

// In a SvelteKit + Svelte file (e.g., +page.js or +layout.js)
export async function load({ url }) {
  try {
    const user = await fetchUser();
  } catch(err) {
    toast.error(err.message);
    goto('/account/login');
  }

  if(!global.user) {
    error(401, 'Not logged in');
    return;
  }

  return {
    user: global.user,
  };
}
