// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah

import { toast } from 'svelte-sonner';
import { global } from '$lib/shared.svelte';

// on error show error toast
export async function fetchToast(path, params) {
  const xcsrf = global.xcsrf;
  try {
    const response = await fetch(path, {
      method: "post",
      body: JSON.stringify({
        ...params,
        [xcsrf.name]: xcsrf.value,
      }),
    });

    const r_json = await response.json();
    if (r_json.error_message) {
     throw new Error(r_json.error_message);
    }

    return r_json;
  } catch (err) {
    toast.error(err.message);
  }
}

