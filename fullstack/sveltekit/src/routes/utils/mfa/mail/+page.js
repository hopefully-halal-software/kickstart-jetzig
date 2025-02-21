// بسم الله الرحمن الرحيم
// la ilaha illa Allah Mohammed Rassoul Allah
import { error } from '@sveltejs/kit';

export function load({ url }) {
    const encrypted_data = url.searchParams.get("data");
    if(!encrypted_data) error(422);
    return {
        encrypted_data: encrypted_data,
    };
}


export const prerender = false;

