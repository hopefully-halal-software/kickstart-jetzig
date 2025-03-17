<script>
  import { page } from '$app/state';
  import NotLoggedIn from '$lib/components/errors/NotLoggedIn.svelte';
</script>

{#if page.status === 401 && page.error.message === 'Not logged in'}
  <NotLoggedIn/>
{:else}
  <h1>{page.status} {page.error.message}</h1>
{/if}
