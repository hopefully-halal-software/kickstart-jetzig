<script>
  let { data } = $props();
  const user = data.user;
  import AuthenticityFormElement from "$lib/components/authenticityFormElement.svelte";
</script>

<div class="container mx-auto mt-12">
  <div class="card mx-auto w-1/2 px-12 py-7 preset-outlined-surface-200-800 bg-surface-50-950">
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
    <form class="mt-3 pl-3" action="/account/logout" method="POST">
      <AuthenticityFormElement {data}/>
      <button type="submit" class="btn preset-filled-error-500">Logout</button>
    </form>
  </div>
</div>

