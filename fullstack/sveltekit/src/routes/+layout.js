// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
// This can be false if you're using a fallback (i.e. SPA mode)
export const ssr = false;
export const prerender = 'auto';
export const csr = true;
// export const trailingSlash = 'always';

import { toast } from 'svelte-sonner';
import { global, fetchXcsrfToken, fetchUser } from '$lib/shared.svelte';

export async function load() {
  const xcsrf = await fetchXcsrfToken();
  try {
	const user = await fetchUser();
  } catch(err) {
    toast.error(err.message);
  }

	return { xcsrf: global.xcsrf };
}
