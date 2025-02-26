<script>
  let { data } = $props();
  const user = data.user;
  import AuthenticityFormElement from "$lib/components/authenticityFormElement.svelte";
</script>

<main>
  <h1>Account Information</h1>
  <p>Name: {user.name}</p>
  <p>Email: {user.email}</p>
  <p>Account Created At: {user.created_at}</p>
  <form action="/account/logout" method="POST">
	<AuthenticityFormElement {data}/>
    <button type="submit" class="btn preset-filled-error-500">Logout</button>
  </form>
</main>

