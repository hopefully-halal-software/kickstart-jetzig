// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
// This can be false if you're using a fallback (i.e. SPA mode)
export const ssr = false;
export const prerender = 'auto';
export const csr = true;
// export const trailingSlash = 'always';

import { global } from '$lib/shared.svelte';

export async function load() {
	if ( global.xcsrf ) return { xcsrf: global.xcsrf };
	const response = await fetch('/api/v1/auth/tokens/ani-csrf.json');
	if (!response.ok) {
	    throw new Error('Failed to get xsrf token (status: ' + response.status + ', body: \'' + response.body + '\')');
	}
	const data = await response.json();
	global.xcsrf = { name: data.name, value: data.value };
	return { xcsrf: global.xcsrf };
}
