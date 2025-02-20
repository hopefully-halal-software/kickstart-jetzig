<script>
  let { data } = $props();
  const user = data.user;
</script>

<main>
  <h1>Account Information</h1>
  <p>Name: {user.name}</p>
  <p>Email: {user.email}</p>
  <p>Account Created At: {user.created_at}</p>
</main>

