// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

import { toast } from 'svelte-sonner';
import { goto } from '$app/navigation';
import { global, fetchUser } from '$lib/shared.svelte';

// In a SvelteKit + Svelte file (e.g., +page.js or +layout.js)
export async function load({ url }) {
  try {
    const user = await fetchUser();
  } catch(err) {
    toast.error(err.message);
    goto('/account/login');
  }

  return {
    user: global.user,
  };
}
