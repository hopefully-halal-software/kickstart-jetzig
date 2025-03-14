<script>
  let { data } = $props();
  const user = data.user;

  import { fetchToast } from '$lib/CustomFetch.js';
  import { goto } from '$app/navigation';
  import { removeUser, removeXcsrfToken, fetchXcsrfToken } from '$lib/shared.svelte.js';

</script>

<div class="container mx-auto mt-12">
  <div class="card mx-auto w-1/2 px-12 py-7 preset-outlined-surface-200-800 shadow-xl">
  {#if user}
    <h1 class="text-2xl text-center font-bold">Account Information</h1>
    <p class="mt-4">
      <span class="font-semibold">Name:</span>
      <span>{user.name}</span>
    </p>
    <p class="mt-1">
      <span class="font-semibold">Email:</span>
      <span>{user.email}</span>
    </p>
    <p class="mt-1">
      <span class="font-semibold">Created At:</span>
      <span>{new Date(user.created_at).toLocaleString()}</span>
    </p>
    <form class="mt-3 pl-3" onsubmit={async (e) => {
        await fetchToast('/api/v1/account/logout.json', {});
        await removeUser();
        await removeXcsrfToken();
        await fetchXcsrfToken();
        goto('/account/login');
      }}
    >
      <button type="submit" class="btn preset-filled-error-500">Logout</button>
    </form>
  {:else}
    <h1 class="text-2xl text-center font-bold">Not logged in</h1>
    <fieldset class="flex justify-around mt-8 p-5 text-lg font-medium">
      <a href="/account/login" class="preset-filled-primary-500 btn">Login</a>
      <span>or</span>
      <a href="/account/register" class="preset-filled-primary-500 btn">Register</a>
    </fieldset>
  {/if}
  </div>
</div>
  


