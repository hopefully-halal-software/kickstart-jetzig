// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
// This can be false if you're using a fallback (i.e. SPA mode)
export const ssr = false;
export const prerender = 'auto';
export const csr = true;
// export const trailingSlash = 'always';

import { global, fetchXcsrfToken } from '$lib/shared.svelte';

export async function load() {
	const xcsrf = await fetchXcsrfToken();

	return { xcsrf: global.xcsrf };
}
